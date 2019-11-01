//
//  OrderEntity.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData

class OrderEntity: NSManagedObject {
    
    //MARK: - CLASS METHODS
    class func findOrCreate(_ order: OrderModel, context: NSManagedObjectContext) throws -> OrderEntity {
        if let orderEntity = try OrderEntity.find(order: order, context: context) {
            
            return orderEntity
        } else {
            guard let provider = DataService.shared.findUser(byID: order.providerID) as? ProviderEntity, let client = DataService.shared.findUser(byID: order.clientID) as? ClientEntity else {
                throw OrderCreationErrors.couldntFindUser
            }
            guard let service = try ServiceEntity.find(serviceName: order.serviceName, serviceProviderID: order.providerID, context: context) else {
                throw OrderCreationErrors.CouldntFindService
            }
            
            let orderEntity = OrderEntity(context: context)
            orderEntity.date = order.date
            orderEntity.client = client
            orderEntity.provider = provider
            orderEntity.service = service
            
            print("order created")
            return orderEntity
        }
    }
    
    class func find(order: OrderModel, context: NSManagedObjectContext) throws -> OrderEntity? {
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "date == %@ AND client.id == %@ AND provider.id == %@", argumentArray: [order.date, order.clientID, order.providerID])
        let fetchResult = try context.fetch(request)
            
        return fetchResult.first
    }
    
    class func findAll(context: NSManagedObjectContext) throws -> [OrderEntity] {
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        let fetchResult = try context.fetch(request)
            
        return fetchResult
    }
    
    class func find(forUser user: UserModel, context: NSManagedObjectContext) throws -> [OrderEntity] {
        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        print(user.id)
        request.predicate = NSPredicate(format: "client.id == %@ OR provider.id == %@", argumentArray: [user.id, user.id])
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let fetchResult = try context.fetch(request)
            return fetchResult
        } catch {
            print(error)
            return []
        }
    }
    
    class func find(forUserByID id: UUID, andDate date: Date, context: NSManagedObjectContext) throws -> [OrderEntity]? {
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: date)
        let minutes = calendar.component(.minute, from: date)
        let endDateForward = calendar.date(bySettingHour: hour + 1, minute: minutes, second: 0, of: date)
        let endDateBackward = calendar.date(bySettingHour: hour - 1, minute: minutes, second: 0, of: date)

        let request: NSFetchRequest<OrderEntity> = OrderEntity.fetchRequest()
        request.predicate = NSPredicate(format: "provider.id == %@ AND (date > %@ AND date < %@)", argumentArray: [id, endDateBackward as Any, endDateForward as Any])
        request.sortDescriptors = [NSSortDescriptor(key: "date", ascending: false)]
        do {
            let fetchResult = try context.fetch(request)
            return fetchResult
        } catch {
            print(error)
            return nil
        }
    }
    //MARK: -
}

//MARK: - ERRORS
enum OrderCreationErrors: Error {
    case couldntFindUser
    case CouldntFindService
}
//MARK: -
