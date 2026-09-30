// ===== Editor de avatar por partes (DiceBear, estilo "adventurer") =====
(function () {
    const BASE = 'https://api.dicebear.com/9.x/adventurer/svg';

    // Genera listas como ["variant01", "variant02", ...]
    function rango(prefijo, cantidad) {
        return Array.from({ length: cantidad }, function (_, i) {
            return prefijo + String(i + 1).padStart(2, '0');
        });
    }

    // Partes con flechitas  ('' = Ninguno)
    const PARTES = [
        { clave: 'hair', nombre: 'Pelo', opciones: rango('short', 19).concat(rango('long', 26)) },
        { clave: 'eyes', nombre: 'Ojos', opciones: rango('variant', 26) },
        { clave: 'eyebrows', nombre: 'Cejas', opciones: rango('variant', 15) },
        { clave: 'mouth', nombre: 'Boca', opciones: rango('variant', 30) },
        { clave: 'glasses', nombre: 'Lentes', opciones: [''].concat(rango('variant', 5)) },
        { clave: 'earrings', nombre: 'Aretes', opciones: [''].concat(rango('variant', 6)) },
        { clave: 'features', nombre: 'Detalles', opciones: ['', 'blush', 'freckles', 'birthmark', 'mustache'] }
    ];
    const OPCIONALES = ['glasses', 'earrings', 'features'];

    // Partes con bolitas de color
    const COLORES = [
        { clave: 'skinColor', nombre: 'Piel', opciones: ['f2d3b1', 'ecad80', '9e5622', '763900'] },
        { clave: 'hairColor', nombre: 'Color de pelo', opciones: ['0e0e0e', '562306', '6a4e35', 'ac6511', 'cb6820', 'ab2a18', 'e5d7a3', 'b9a05f', 'afafaf', '3eac2c', '85c2c6', 'dba3be', '592454'] },
        { clave: 'backgroundColor', nombre: 'Fondo', opciones: ['dce6cb', 'c5d3ac', 'b7d2d4', 'f3f6ec', 'e9d8ef', 'f6e3c8'] }
    ];

    // Avatar por defecto (podés cambiar estos números por una carita que te guste)
    const estado = {
        hair: 'short01', eyes: 'variant01', eyebrows: 'variant01', mouth: 'variant01',
        glasses: '', earrings: '', features: '',
        skinColor: 'f2d3b1', hairColor: '0e0e0e', backgroundColor: 'dce6cb'
    };

    const campo = document.getElementById('AvatarUrl');
    const imagen = document.getElementById('avatar-imagen');
    const inicial = document.getElementById('avatar-inicial');
    const editor = document.getElementById('avatar-editor');
    const valores = {};  // el texto "3 de 45" de cada parte
    const muestras = {}; // las bolitas de color de cada grupo

    // Arma la URL de DiceBear con lo elegido
    function construirUrl() {
        const p = new URLSearchParams();
        p.set('seed', 'mapiticos');
        p.set('skinColor', estado.skinColor);
        p.set('hair', estado.hair);
        p.set('hairColor', estado.hairColor);
        p.set('eyes', estado.eyes);
        p.set('eyebrows', estado.eyebrows);
        p.set('mouth', estado.mouth);
        OPCIONALES.forEach(function (clave) {
            if (estado[clave]) {
                p.set(clave, estado[clave]);
                p.set(clave + 'Probability', '100');
            } else {
                p.set(clave + 'Probability', '0');
            }
        });
        p.set('backgroundColor', estado.backgroundColor);
        return BASE + '?' + p.toString();
    }

    // Si ya tenía un avatar hecho con este editor, carga sus partes
    function leerUrl(url) {
        if (!url || url.indexOf(BASE + '?') !== 0) return;
        const p = new URLSearchParams(url.substring(BASE.length + 1));

        PARTES.forEach(function (parte) {
            const valor = p.get(parte.clave);
            const esOpcional = OPCIONALES.indexOf(parte.clave) >= 0;
            if (esOpcional && p.get(parte.clave + 'Probability') === '0') {
                estado[parte.clave] = '';
            } else if (valor && parte.opciones.indexOf(valor) >= 0) {
                estado[parte.clave] = valor;
            }
        });

        COLORES.forEach(function (grupo) {
            const valor = p.get(grupo.clave);
            if (valor && grupo.opciones.indexOf(valor) >= 0) {
                estado[grupo.clave] = valor;
            }
        });
    }

    function textoParte(parte) {
        if (estado[parte.clave] === '') return 'Ninguno';
        const esOpcional = OPCIONALES.indexOf(parte.clave) >= 0;
        const indice = parte.opciones.indexOf(estado[parte.clave]);
        const numero = esOpcional ? indice : indice + 1;
        const total = esOpcional ? parte.opciones.length - 1 : parte.opciones.length;
        return numero + ' de ' + total;
    }

    // Refresca la vista previa, los textos y las bolitas seleccionadas
    function actualizar() {
        const url = construirUrl();
        campo.value = url;
        imagen.src = url;

        PARTES.forEach(function (parte) {
            valores[parte.clave].textContent = textoParte(parte);
        });

        COLORES.forEach(function (grupo) {
            muestras[grupo.clave].forEach(function (boton) {
                boton.setAttribute('aria-pressed', boton.dataset.color === estado[grupo.clave] ? 'true' : 'false');
            });
        });
    }

    function mover(parte, paso) {
        const total = parte.opciones.length;
        const indice = parte.opciones.indexOf(estado[parte.clave]);
        estado[parte.clave] = parte.opciones[(indice + paso + total) % total];
        actualizar();
    }

    function crearFlecha(icono, etiqueta, alHacerClic) {
        const boton = document.createElement('button');
        boton.type = 'button';
        boton.className = 'parte-boton';
        boton.setAttribute('aria-label', etiqueta);
        const i = document.createElement('i');
        i.className = 'ti ' + icono;
        i.setAttribute('aria-hidden', 'true');
        boton.append(i);
        boton.addEventListener('click', alHacerClic);
        return boton;
    }

    // ===== Filas de partes =====
    const contenedorPartes = document.getElementById('avatar-partes');
    PARTES.forEach(function (parte) {
        const fila = document.createElement('div');
        fila.className = 'parte-fila';

        const nombre = document.createElement('span');
        nombre.className = 'parte-nombre';
        nombre.textContent = parte.nombre;

        const valor = document.createElement('span');
        valor.className = 'parte-valor';
        valor.setAttribute('aria-live', 'polite');
        valores[parte.clave] = valor;

        fila.append(
            nombre,
            crearFlecha('ti-chevron-left', parte.nombre + ': anterior', function () { mover(parte, -1); }),
            valor,
            crearFlecha('ti-chevron-right', parte.nombre + ': siguiente', function () { mover(parte, 1); })
        );
        contenedorPartes.append(fila);
    });

    // ===== Bolitas de color =====
    const contenedorColores = document.getElementById('avatar-colores');
    COLORES.forEach(function (grupo) {
        const bloque = document.createElement('div');
        bloque.className = 'color-grupo';
        bloque.setAttribute('role', 'group');
        bloque.setAttribute('aria-label', grupo.nombre);

        const titulo = document.createElement('span');
        titulo.className = 'color-grupo-nombre';
        titulo.textContent = grupo.nombre;

        const fila = document.createElement('div');
        fila.className = 'muestras';

        muestras[grupo.clave] = grupo.opciones.map(function (color, i) {
            const boton = document.createElement('button');
            boton.type = 'button';
            boton.className = 'muestra';
            boton.dataset.color = color;
            boton.style.background = '#' + color;
            boton.setAttribute('aria-label', grupo.nombre + ', opción ' + (i + 1));
            boton.addEventListener('click', function () {
                estado[grupo.clave] = color;
                actualizar();
            });
            fila.append(boton);
            return boton;
        });

        bloque.append(titulo, fila);
        contenedorColores.append(bloque);
    });

    // ===== Botón "Al azar" =====
    document.getElementById('avatar-azar').addEventListener('click', function () {
        const azar = function (lista) { return lista[Math.floor(Math.random() * lista.length)]; };
        PARTES.forEach(function (parte) { estado[parte.clave] = azar(parte.opciones); });
        COLORES.forEach(function (grupo) { estado[grupo.clave] = azar(grupo.opciones); });
        actualizar();
    });

    // ===== "Mi inicial" / "Crear mi avatar" =====
    function cambiarModo(modo) {
        const personalizado = modo === 'personalizado';
        editor.hidden = !personalizado;
        imagen.hidden = !personalizado;
        inicial.hidden = personalizado;
        if (personalizado) {
            actualizar();
        } else {
            campo.value = ''; // sin avatar = se usa la inicial
        }
    }

    document.querySelectorAll('input[name="modoAvatar"]').forEach(function (radio) {
        radio.addEventListener('change', function () { cambiarModo(radio.value); });
    });

    // ===== Al abrir la página =====
    leerUrl(campo.value);
    const modoMarcado = document.querySelector('input[name="modoAvatar"]:checked');
    cambiarModo(modoMarcado ? modoMarcado.value : 'inicial');
})();