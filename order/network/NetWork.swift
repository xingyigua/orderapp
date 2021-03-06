//
//  NetWork.swift
//  order
//
//  Created by yigua on 2022/4/14.
//

import Foundation
import Moya
import Defaults

let apiProvider = MoyaProvider<API>.init(endpointClosure: MoyaProvider.defaultEndpointMapping,
                                      requestClosure: MoyaProvider<API>.defaultRequestMapping,
                                      stubClosure: MoyaProvider.neverStub,
                                      callbackQueue: nil,
                                      session: MoyaProvider<API>.defaultAlamofireSession(),
                                      plugins: [NetworkLoggerPlugin.verbose],
                                      trackInflights: false)

enum API {
    case userLogin(username: String, password: String)
    case userLogout
    case changePassword(old: String, new: String)
    
    case allUsers
    case addUser(detail: [String: Any])
    case deleteUser(id: String)

    case allRooms
    case roomDetail(id: String)
    case changeRoomDetail(id: String, detail: [String: Any])
    case addRoom(detail: [String: Any])
    case deleteRoom(id: String)
    
    case order(user: String, room: String, date: String)
    case orders(user: String?)
}


extension API: TargetType {
    
    var baseURL: URL {
        return URL(string: "http://127.0.0.1:8080")!
    }
    
    var path: String {
        switch self {
        case .userLogin:
            return "/user/login"
        case .userLogout:
            return "/user/register"
        case .allRooms, .addRoom:
            return "/rooms"
        case .roomDetail(let id), .changeRoomDetail(let id, _), .deleteRoom(let id):
            return "/rooms/\(id)"
        case .allUsers, .addUser:
            return "/users"
        case .deleteUser(let id):
            return "/users/\(id)"
        case .changePassword:
            return "/user/changePassword"
        case .order, .orders:
            return "/orders"
        }
    }
    
    var method: Moya.Method {
        switch self {
        case .userLogin, .userLogout, .addRoom, .addUser, .changePassword, .order:
            return .post
        case .allRooms, .roomDetail, .allUsers, .orders:
            return .get
        case .changeRoomDetail:
            return .put
        case .deleteRoom, .deleteUser:
            return .delete
        }
    }
    
    var task: Task {
        var body: [String: Any] = [:]
        var query: [String: Any] = [:]
        switch self {
        case let .userLogin(username, password):
            body = ["username": username, "password": password]
            query = [:]
        case .userLogout:
            body = [:]
        case .allRooms:
            break
        case .roomDetail:
            break
        case let .changeRoomDetail(_, detail), let .addRoom(detail), let .addUser(detail):
            body = detail
        case .deleteRoom:
            break
        case .allUsers:
            break
        case .deleteUser:
            break
        case let .changePassword(old, new):
            body = ["old": old, "new": new]
        case let .order(user, room, date):
            body = ["user": user, "room": room, "date": date]
        case let .orders(user):
            if let user = user {
                query = ["user": user]
            }
        }
        if method == .get {
            return .requestParameters(parameters: query, encoding: URLEncoding.queryString)
        }
        return .requestCompositeParameters(bodyParameters: body, bodyEncoding: JSONEncoding.default, urlParameters: query)
    }
    
    var headers: [String : String]? {
        if let id = Defaults[.user]?.id {
            return ["id": id]
        }
        return nil
    }
    
}
