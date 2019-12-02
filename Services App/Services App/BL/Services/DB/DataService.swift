//
//  DataService.swift
//  Services App
//
//  Created by Perov Alexey on 11.10.2019.
//  Copyright © 2019 Perov Alexey. All rights reserved.
//

import Foundation
import CoreData
import CoreStore

class DataService {
    
    static let shared = DataService()
    let sharedCoreStore = DataStack(xcodeModelName: "Services_App")

    
    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "Services_App")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    @discardableResult
    func create(client: ClientModel) throws -> ClientEntity {
        let client = try ClientEntity.findOrCreate(client, stack: sharedCoreStore)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return client
    }
    
    @discardableResult
    func create(provider: ProviderModel, profession: ProfessionModel) throws -> ProviderEntity {
        let provider = try ProviderEntity.findOrCreate(provider, profession: profession, stack: sharedCoreStore)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return provider
    }
    
    @discardableResult
    func create(service: ServiceModel) throws -> ServiceEntity {
        let service = try ServiceEntity.findOrCreate(service, stack: sharedCoreStore)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return service
    }
    
    @discardableResult
    func create(order: OrderModel) throws -> OrderEntity {
        let order = try OrderEntity.findOrCreate(order, stack: sharedCoreStore)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return order
    }
    
    func complete(order: OrderModel, finalPrice: Decimal) throws {
        if let orderToDelete = try OrderEntity.find(order: order, stack: sharedCoreStore) {
            try sharedCoreStore.perform(synchronous: { transaction in
                let orderToEdit = transaction.edit(orderToDelete)!
                orderToEdit.completionDate = Date()
                orderToEdit.finalPrice = finalPrice as NSDecimalNumber
            })
        } else {
            print("couldn't find order")
        }
    }
    
    func delete(service: ServiceModel) throws {
        if let serviceToDelete = try ServiceEntity.find(serviceName: service.name, serviceProviderID: service.providerID, stack: sharedCoreStore) {
            try sharedCoreStore.perform(synchronous: { transaction in
                let serviceToDelete = transaction.edit(serviceToDelete)!
                transaction.delete(serviceToDelete)
            })
        } else {
            print("couldn't find service")
        }
    }
    
    func findOrders(forUser user: UserModel) throws -> [OrderModel] {
        do {
            let orderEntities = try OrderEntity.find(forUser: user, stack: sharedCoreStore)
            return orderEntities.compactMap { OrderModel(fromEntity: $0) }
        } catch {
            print(error)
        }
        return []
    }
    
    func findOrders(forUser user: UserModel, completed: Bool) throws -> [OrderModel] {
        do {
            let orderEntities = try OrderEntity.find(forUser: user, complete: completed, stack: sharedCoreStore)
            return orderEntities.compactMap { OrderModel(fromEntity: $0) }
        } catch {
            print(error)
        }
        return []
    }
    
    func canFindUser(withLogin login: String) -> Bool {
        if let _ = try? UserEntity.findWithLogin(login: login, stack: sharedCoreStore) {
            return true
        } else {
            return false
        }
    }
    
    func findUser(withLogin login: String, andPassword password: String) -> UserModel? {
        let user = try? UserEntity.findProfile(login: login, password: password, stack: sharedCoreStore)
        if let client = user as? ClientEntity {
            if let clientModel = ClientModel(fromEntity: client) {
                return clientModel
            }
        }
        if let provider = user as? ProviderEntity {
            if let providerModel = ProviderModel(fromEntity: provider) {
                return providerModel
            }
        }
        return nil
     }
    
    func findUser(byID id: UUID) -> UserEntity? {
        return try? UserEntity.find(userId: id, stack: sharedCoreStore)
    }
    
    func findServicesFor(provider: ProviderModel) -> [ServiceModel] {
        let serviceEntities = try? ProviderEntity.findServices(userID: provider.id, stack: sharedCoreStore)
        let serviceModels = serviceEntities?.compactMap { ServiceModel(fromEntity: $0) }
        
        return serviceModels ?? []
    }
    
    func find(service: ServiceModel) -> ServiceEntity? {
        return try? ServiceEntity.find(serviceName: service.name, serviceProviderID: service.providerID, stack: sharedCoreStore)
    }
    
    func getSettings() throws -> SettingsEntity {
        let settings = try SettingsEntity.findOrCreate(stack: sharedCoreStore)
        return settings
    }
    
    func findServices() -> [ServiceModel] {
        let serviceEntities = try? ServiceEntity.findAll(stack: sharedCoreStore)
        let serviceModels = serviceEntities?.compactMap { ServiceModel(fromEntity: $0) }
        
        return serviceModels ?? []
    }
    
//    func findAllUsers() throws -> [UserModel] {
//        let entities = try UserEntity.findAll(stack: sharedCoreStore)
//
//    }
    
    func findOrders(forUserByID id: UUID, date: Date) throws -> [OrderModel]? {
        let orderEntities = try OrderEntity.find(forUserByID: id, andDate: date, stack: sharedCoreStore)
        let orderModels = orderEntities?.compactMap { OrderModel(fromEntity: $0) }
        return orderModels
    }
    
    func rememberUser(_ user: UserModel) throws {
        let settings = try getSettings()
        let user = try UserEntity.find(userId: user.id, stack: sharedCoreStore)
        try DataService.shared.sharedCoreStore.perform(synchronous: { transaction in
            let settings = transaction.edit(settings)!
            let user = transaction.edit(user)!
            settings.currentUser = user
        })
    }
    
    func getCurrentUser() throws -> UserModel? {
        let settings = try DataService.shared.getSettings()
        if let aUser = settings.currentUser {
            if let userEntity = aUser as? ClientEntity, let userModel = ClientModel(fromEntity: userEntity) {
                return userModel
            }
            if let userEntity = aUser as? ProviderEntity, let userModel = ProviderModel(fromEntity: userEntity) {
                return userModel
            }
        }
        return nil
    }
    
    func logOut() {
        let settings = try? getSettings()
        try? sharedCoreStore.perform(synchronous: { transaction in
            let settings = transaction.edit(settings)!
            settings.currentUser = nil
        })
    }
    
    private init() {
        try? sharedCoreStore.addStorageAndWait()
        
    }
    
}
