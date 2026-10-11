# Guía de Contribución y Reglas del Repositorio

Bienvenidos al repositorio del Procesador de 8 bits. Para mantener el orden, evitar conflictos y asegurar que el código de todos se integre correctamente, es obligatorio seguir las reglas detalladas en este documento.

## 🗣️ 1. Idioma Oficial
**Todo el desarrollo en este repositorio debe realizarse en español.** 
Esto incluye:
- Mensajes de commit.
- Títulos y descripciones de los Pull Requests (PR).
- Comentarios dentro del código SystemVerilog.
- Documentación (README, guías, etc.).

---

## 🌿 2. Gestión de Ramas (Branches)
Nunca se debe trabajar directamente sobre la rama `main`. La rama `main` está protegida y solo debe contener código funcional y verificado.

Cada grupo debe crear y trabajar en su propia rama basándose en el bloque que tienen asignado. 
**Formato de nombres de ramas:** `grupoX-nombre_del_bloque` o `grupoX-feature`

*Ejemplos:*
- `grupo1-control`
- `grupo2-alu-operaciones`
- `grupo3-banco-registros`

---

## 📝 3. Convención de Commits
Para mantener un historial limpio y entendible, utilizaremos el siguiente formato para los mensajes de commit:

`tipo(bloque): descripción corta y en imperativo`

**Tipos permitidos:**
- `feat`: Nueva característica o módulo (ej. nueva operación en la ALU).
- `fix`: Corrección de un error (ej. arreglar un glitch en la simulación).
- `test`: Añadir o modificar testbenches.
- `docs`: Cambios en la documentación o README.
- `refactor`: Cambios en el código que no alteran su funcionalidad (ej. ordenar el código).

**Ejemplos de commits correctos:**
- `feat(alu): agregar operación XOR y cálculo de bandera de paridad`
- `fix(control): corregir transición de estado en instrucción de salto`
- `test(registros): agregar testbench para escritura simultánea`
- `docs(readme): actualizar tabla de asignación de grupos`

---

## 🔄 4. Flujo de Trabajo (Workflow) Paso a Paso

Sigan este flujo cada vez que vayan a trabajar en el proyecto:

1. **Sincronizar el repositorio local:** Antes de empezar, asegúrense de tener los últimos cambios.
   ```bash
   git checkout main
   git pull origin main
   ```
2. **Crear o moverse a su rama de trabajo:**
   ```bash
   git checkout -b grupo1-control
   ```
   *(Si la rama ya existe, usen `git checkout grupo1-control`)*
3. **Desarrollar y Testear:** 
   Escriban su código en SystemVerilog. **Importante:** Todo módulo debe simularse con su testbench correspondiente antes de ser subido.
4. **Hacer Commits:** Guarden sus cambios de forma lógica y frecuente usando la convención mencionada.
   ```bash
   git add .
   git commit -m "feat(io): agregar sincronizador para entradas de botones"
   ```
5. **Subir los cambios al repositorio:**
   ```bash
   git push origin grupo1-control
   ```
6. **Crear un Pull Request (PR):** Vayan a GitHub/GitLab y abran un PR desde su rama hacia `main`. Expliquen en la descripción qué hicieron y si hay algo que los revisores deban probar.

---

## 🛡️ 5. Revisión de Código y Pull Requests (PRs)
- **Prohibido el auto-merge:** Ningún grupo puede aceptar (mergear) su propio Pull Request.
- **Revisión obligatoria:** Todo PR debe ser revisado y aprobado por al menos **un integrante de otro grupo** antes de integrarse a `main`.
- El revisor debe comprobar que el código compile, que el testbench pase y que se sigan las convenciones de diseño (nombres de puertos, sincronismo, etc.).

---

## 🤖 6. Uso de Inteligencia Artificial (IA)
El uso de asistentes de IA (ChatGPT, Claude, Gemini, Copilot, etc.) **está permitido**, pero con reglas claras alineadas a la materia:

**✅ SÍ usar IA para:**
- Resolver dudas sobre sintaxis de SystemVerilog.
- Estructurar el esqueleto de un Testbench.
- Interpretar mensajes de error de compilación o simulación (Questa / Quartus).
- Entender cómo instanciar módulos o resolver problemas de conexionado.

**❌ NO usar IA para:**
- Tomar decisiones de arquitectura sin entenderlas (ej. definir los estados de la Unidad de Control a ciegas).
- Diseñar la lógica de un bloque completo y copiarlo sin poder justificar por qué funciona.


*Nota: Las decisiones de diseño son tomadas por los integrantes del grupo en su totalidad, no debe ser decidida de ninguna manera por una inteligencia artificial.*