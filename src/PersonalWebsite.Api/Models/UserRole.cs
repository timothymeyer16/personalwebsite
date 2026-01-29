namespace PersonalWebsite.Api.Models;

/// <summary>
/// Join table for many-to-many relationship between Users and Roles.
/// </summary>
public class UserRole
{
    public int UserId { get; set; }
    public User User { get; set; } = null!;
    
    public int RoleId { get; set; }
    public Role Role { get; set; } = null!;
    
    public DateTime AssignedAt { get; set; } = DateTime.UtcNow;
}
