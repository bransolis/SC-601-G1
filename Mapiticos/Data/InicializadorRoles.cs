using Microsoft.AspNetCore.Identity;

namespace Mapiticos.Data
{
    public static class InicializadorRoles
    {
        public const string Usuario = "Usuario";
        public const string Admin = "Admin";

        public static async Task CrearRolesAsync(IServiceProvider servicios)
        {
            var roleManager = servicios.GetRequiredService<RoleManager<IdentityRole>>();

            foreach (var rol in new[] { Usuario, Admin })
            {
                if (!await roleManager.RoleExistsAsync(rol))
                {
                    await roleManager.CreateAsync(new IdentityRole(rol));
                }
            }
        }
    }
}