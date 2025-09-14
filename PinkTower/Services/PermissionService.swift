import Foundation

protocol PermissionServiceProtocol {
    func canManageGuides(_ guide: Guide) -> Bool
    func canManageStudents(_ guide: Guide) -> Bool
    func canManageClassrooms(_ guide: Guide) -> Bool
}

struct PermissionService: PermissionServiceProtocol {
    func canManageGuides(_ guide: Guide) -> Bool {
        guide.role == .superAdmin
    }
    func canManageStudents(_ guide: Guide) -> Bool {
        guide.role == .superAdmin || guide.role == .admin
    }
    func canManageClassrooms(_ guide: Guide) -> Bool {
        guide.role == .superAdmin || guide.role == .admin
    }
}


