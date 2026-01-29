namespace PersonalWebsite.Api.Models;

/// <summary>
/// Represents a user in the system, linked to Azure AD B2C identity.
/// </summary>
public class User
{
    public int Id { get; set; }
    
    /// <summary>
    /// The Object ID from Azure AD B2C (sub claim in JWT).
    /// </summary>
    public required string ExternalId { get; set; }
    
    public required string Email { get; set; }
    
    public string? DisplayName { get; set; }
    
    public string? FirstName { get; set; }
    
    public string? LastName { get; set; }
    
    public DateTime CreatedAt { get; set; } = DateTime.UtcNow;
    
    public DateTime? LastLoginAt { get; set; }
    
    public bool IsActive { get; set; } = true;
    
    // Navigation properties
    public ICollection<UserRole> UserRoles { get; set; } = new List<UserRole>();
}
