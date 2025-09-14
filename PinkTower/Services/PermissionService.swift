import Foundation

protocol PermissionServiceProtocol {
    func canManageGuides(_ guide: Guide, orgRole: OrgRole?) -> Bool
    func canManageStudents(_ guide: Guide, orgRole: OrgRole?) -> Bool
    func canManageClassrooms(_ guide: Guide, orgRole: OrgRole?) -> Bool
    func canCreateStudentContent(_ guide: Guide, orgRole: OrgRole?) -> Bool
}

struct PermissionService: PermissionServiceProtocol {
    func canManageGuides(_ guide: Guide, orgRole: OrgRole?) -> Bool { orgRole == .superAdmin }
    func canManageStudents(_ guide: Guide, orgRole: OrgRole?) -> Bool { orgRole == .superAdmin || orgRole == .admin }
    func canManageClassrooms(_ guide: Guide, orgRole: OrgRole?) -> Bool { orgRole == .superAdmin || orgRole == .admin }
    func canCreateStudentContent(_ guide: Guide, orgRole: OrgRole?) -> Bool { true }
}


