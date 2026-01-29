namespace PersonalWebsite.Api.Models;

/// <summary>
/// Represents a role that can be assigned to users.
/// </summary>
public class Role
{
    public int Id { get; set; }
    
    public required string Name { get; set; }
    
    public string? Description { get; set; }
    
    // Navigation properties
    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
