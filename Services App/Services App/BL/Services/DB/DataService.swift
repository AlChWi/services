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
        let client = try ClientEntity.findOrCreate(client, context: persistentContainer.viewContext)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return client
    }
    
    @discardableResult
    func create(provider: ProviderModel, profession: ProfessionModel) throws -> ProviderEntity {
        let provider = try ProviderEntity.findOrCreate(provider, profession: profession, context: persistentContainer.viewContext)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return provider
    }
    
    @discardableResult
    func create(service: ServiceModel) throws -> ServiceEntity {
        let service = try ServiceEntity.findOrCreate(service, context: persistentContainer.viewContext)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return service
    }
    
    @discardableResult
    func create(order: OrderModel) throws -> OrderEntity {
        let order = try OrderEntity.findOrCreate(order, context: persistentContainer.viewContext)
        if persistentContainer.viewContext.hasChanges {
            try persistentContainer.viewContext.save()
        }
        return order
    }
    
    func delete(order: OrderModel) throws {
        let context = persistentContainer.viewContext
        if let orderToDelete = try OrderEntity.find(order: order, context: context) {
            context.delete(orderToDelete)
        } else {
            print("couldn't find order")
        }
        if context.hasChanges {
            try context.save()
        }
    }
    
    func delete(service: ServiceModel) throws {
        let context = persistentContainer.viewContext
        if let serviceToDelete = try ServiceEntity.find(serviceName: service.name, serviceProviderID: service.providerID, context: context) {
            context.delete(serviceToDelete)
        } else {
            print("couldn't find service")
        }
        if context.hasChanges {
            try context.save()
        }
    }
    
    func findOrders(forUser user: UserModel) throws -> [OrderModel] {
        do {
            let orderEntities = try OrderEntity.find(forUser: user, context: persistentContainer.viewContext)
            return orderEntities.compactMap { OrderModel(fromEntity: $0) }
        } catch {
            print(error)
        }
        return []
    }
    
    func canFindUser(withLogin login: String) -> Bool {
        if let _ = try? UserEntity.findWithLogin(login: login, context: persistentContainer.viewContext) {
            return true
        } else {
            return false
        }
    }
    
    func findUser(withLogin login: String, andPassword password: String) -> UserModel? {
        let user = try? UserEntity.findProfile(login: login, password: password, context: persistentContainer.viewContext)
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
        return try? UserEntity.find(userId: id, context: persistentContainer.viewContext)
    }
    
    func findServicesFor(provider: ProviderModel) -> [ServiceModel] {
        let serviceEntities = try? ProviderEntity.findServices(userID: provider.id, context: persistentContainer.viewContext)
        let serviceModels = serviceEntities?.compactMap { ServiceModel(fromEntity: $0) }
        
        return serviceModels ?? []
    }
    
    func find(service: ServiceModel) -> ServiceEntity? {
        return try? ServiceEntity.find(serviceName: service.name, serviceProviderID: service.providerID, context: persistentContainer.viewContext)
    }
    
    func getSettings() throws -> SettingsEntity {
        let settings = try SettingsEntity.findOrCreate(context: persistentContainer.viewContext)
        return settings
    }
    
    func findServices() -> [ServiceModel] {
        let serviceEntities = try? ServiceEntity.findAll(context: persistentContainer.viewContext)
        let serviceModels = serviceEntities?.compactMap { ServiceModel(fromEntity: $0) }
        
        return serviceModels ?? []
    }
    
    func findOrders(forUserByID id: UUID, date: Date) throws -> [OrderModel]? {
        let orderEntities = try OrderEntity.find(forUserByID: id, andDate: date, context: persistentContainer.viewContext)
        let orderModels = orderEntities?.compactMap { OrderModel(fromEntity: $0) }
        return orderModels
    }
    
    func rememberUser(_ user: UserModel) throws {
        let settings = try getSettings()
        let context = persistentContainer.viewContext
        settings.currentUser = try UserEntity.find(userId: user.id, context: context)
        try context.save()
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
        settings?.currentUser = nil
        try? persistentContainer.viewContext.save()
    }
    
    private init() {
        try? sharedCoreStore.addStorage(SQLiteStore(fileName: "Services_App.sqlite"), completion: { (result) in
            switch result {
            case .failure(let error):
                print(error)
            case .success(let store):
                return
            }
        })
    }
    
}
