//
//  OrderEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class OrderEntity: NSManagedObject {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ order: OrderModel, stack: DataStack) throws -> OrderEntity {
        if let orderEntity = try OrderEntity.find(order: order, stack: stack) {
            return orderEntity
        } else {
            try stack.perform(synchronous: { transaction in
                guard
                    let client = try stack.fetchOne(
                        From<ClientEntity>()
                            .where(\.id == order.clientID)
                    ),
                    let service = try stack.fetchOne(
                        From<ServiceEntity>()
                            .where(\.name == order.serviceName && \.toProvider?.id == order.providerID)
                    ),
                    let _ = try stack.fetchOne(
                        From<ProviderEntity>()
                            .where(\.id == service.toProvider?.id)
                    ) else {
                        try transaction.cancel()
                }
                let entity = transaction.create(Into<OrderEntity>())
                let clientRel = transaction.edit(client)!
                let serviceRel = transaction.edit(service)!
                entity.startDate = order.startDate
                entity.client = clientRel
                entity.service = serviceRel
            })
            
            print("order created")
            return try stack.fetchOne(
                From<OrderEntity>()
                    .where(\.startDate == order.startDate && \.service?.toProvider?.id == order.providerID)
                )!
        }
    }
    
    class func find(order: OrderModel, stack: DataStack) throws -> OrderEntity? {
        return try stack.fetchOne(
            From<OrderEntity>()
                .where(\.startDate == order.startDate && \.client?.id == order.clientID && \.service?.toProvider?.id == order.providerID)
        )
    }
    
    class func findAll(stack: DataStack) throws -> [OrderEntity] {
        return try stack.fetchAll(
            From<OrderEntity>()
        )
    }
    
    class func find(forUser user: UserModel, stack: DataStack) throws -> [OrderEntity] {
        return try stack.fetchAll(
            From<OrderEntity>()
                .where(\.client?.id == user.id || \.service?.toProvider?.id == user.id)
                .orderBy(.descending(\.startDate))
        )
    }
    
    class func find(forUser user: UserModel, complete: Bool, stack: DataStack) throws -> [OrderEntity] {
        if complete {
            return try stack.fetchAll(
                From<OrderEntity>()
                    .where((\.client?.id == user.id || \.service?.toProvider?.id == user.id) && \.completionDate != nil)
                    .orderBy(.descending(\.startDate))
            )
        } else {
            return try stack.fetchAll(
                From<OrderEntity>()
                    .where((\.client?.id == user.id || \.service?.toProvider?.id == user.id) && \.completionDate == nil)
                    .orderBy(.descending(\.startDate))
            )
        }
    }
    
//    class func find(forUser user: UserModel, containingName name: String, orInCategory category: String, stack: DataStack) throws -> [OrderEntity]? {
//        return try stack.fetchAll(
//            From<OrderEntity>()
//                .where("%K CONTAINS %@ OR %K CONTAINS %@ OR %K CONTAINS %@ OR %K CONTAINS %@", #keyPath(OrderEntity.client.firstName).lowercased(), user.firstName.lowercased(), #keyPath(OrderEntity.service.toProvider.firstName).lowercased(), user.firstName.lowercased(), #keyPath(OrderEntity.service.name).lowercased(), name.lowercased(), #keyPath(OrderEntity.service.category).lowercased(), category.lowercased())
//        )
//    }
    
    class func find(forUserByID id: UUID, andDate date: Date, stack: DataStack) throws -> [OrderEntity]? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let endDateForward = calendar.date(bySettingHour: hour + 1, minute: minutes, second: 0, of: date)
        let endDateBackward = calendar.date(bySettingHour: hour - 1, minute: minutes, second: 0, of: date)
        
        return try stack.fetchAll(
            From<OrderEntity>()
                .where(\.service?.toProvider?.id == id && \.startDate > endDateBackward && \.startDate < endDateForward)
                .orderBy(.descending(\.startDate))
        )
    }
    //MARK: -
}

//MARK: - ERRORS
enum OrderCreationErrors: Error {
    case couldntFindUser
    case CouldntFindService
}
//MARK: -
