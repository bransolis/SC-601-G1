using Microsoft.AspNetCore.Identity;
using Microsoft.Extensions.Options;

namespace Mapiticos.Data
{
    // Extiende el UserManager de Identity para asignar el rol "Usuario"
    // automáticamente a toda cuenta nueva.
    public class GestorUsuarios : UserManager<IdentityUser>
    {
        public GestorUsuarios(
            IUserStore<IdentityUser> store,
            IOptions<IdentityOptions> optionsAccessor,
            IPasswordHasher<IdentityUser> passwordHasher,
            IEnumerable<IUserValidator<IdentityUser>> userValidators,
            IEnumerable<IPasswordValidator<IdentityUser>> passwordValidators,
            ILookupNormalizer keyNormalizer,
            IdentityErrorDescriber errors,
            IServiceProvider services,
            ILogger<UserManager<IdentityUser>> logger)
            : base(store, optionsAccessor, passwordHasher, userValidators,
                   passwordValidators, keyNormalizer, errors, services, logger)
        {
        }

        public override async Task<IdentityResult> CreateAsync(IdentityUser user, string password)
        {
            // Primero se crea el usuario normalmente
            var resultado = await base.CreateAsync(user, password);

            // Si se creó bien, se le asigna el rol
            if (resultado.Succeeded)
            {
                await AddToRoleAsync(user, InicializadorRoles.Usuario);
            }

            return resultado;
        }
    }
}