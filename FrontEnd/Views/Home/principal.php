<?php
require_once $_SERVER["DOCUMENT_ROOT"] . '/Cliente-Servidor-Farmacia/Views/layout.php';
?>

<!DOCTYPE html>
<html lang="es">

<?php
añadirCSS(); //<head> con CSS
?>

<body>

  <?php
  verheader();
  ?>

  <?php
  sidebar();
  ?>

  <main style="margin-left: 13%">



    <!-- Sección Hero -->
    <section class="hero">
      <div class="hero__container">
        <div class="image-container">
          <img src="../assets/Imagenes/farmacia2.jpg" alt="Imagen de pastillas" class="hero__image" />
        </div>
        <div class="hero__info">
          <h1 class="hero__title">Bienvenido a <span>Farmacia</span>, tu bienestar es nuestra prioridad.</h1>
          <p class="hero__legend">Ofrecemos atención personalizada, productos de calidad y el compromiso de cuidar tu
            salud en todo momento.</p>
          <div class="hero__btn">
            <button class="btn btn__invite">
              <i class="fa-solid fa-arrow-right"></i> Ver productos disponibles
            </button>
          </div>
        </div>
      </div>
    </section>

    <!-- Sección About -->
    <section class="about">
      <div class="about__container">
        <img src="../assets/Imagenes/farmacia4.jpg" alt="Foto farmacia" class="about__image" />
        <div class="about__info">
          <h2 class="about__title">Lo que hacemos</h2>
          <p class="about__text">
            En <span>Farmacia Salud</span>, no solo entregamos medicamentos, somos una familia comprometida con tu
            bienestar y el de quienes más querés...
          </p>
          <p class="about__text">
            Más que una farmacia, somos un espacio de confianza donde recibís atención cercana, orientación profesional
            y productos de calidad...
          </p>
        </div>
      </div>
    </section>

    <!-- Banner decorativo -->
    <div class="banner">
      <div class="banner__content"></div>
    </div>

    <!-- Productos -->
    <section class="menu">
      <div class="menu__container">
        <h2 class="menu__title">Algunos Productos</h2>
        <div class="menu__content">

          <!-- Tarjeta Producto 1 -->
          <div class="card">
            <img class="acetaminofen__image" src="../assets/Imagenes/acetaminofen.jpg" alt="acetaminofen" />
            <div class="menu__info">
              <h3 class="card__title">Pastilla Acetaminofen</h3>
              <p class="card__text">La acetaminofén, también conocido como paracetamol...</p>
              <div class="cart__price">
                <p class="price">₡1.350</p>
                <i class="fa-solid fa-cart-plus"></i>
              </div>
            </div>
          </div>

          <!-- Tarjeta Producto 2 -->
          <div class="card">
            <img class="card__image" src="../assets/Imagenes/colgate2.jpg" alt="COLGATE" />
            <div class="menu__info">
              <h3 class="card__title">Pasta Dental Colgate Triple Acción</h3>
              <p class="card__text">Ayuda a prevenir las caries, combate el mal aliento...</p>
              <div class="cart__price">
                <p class="price">₡2.050</p>
                <i class="fa-solid fa-cart-plus"></i>
              </div>
            </div>
          </div>

          <!-- Tarjeta Producto 3 -->
          <div class="card">
            <img class="card__image" src="../assets/Imagenes/dolo.jpg" alt="DOLO-NEUROBIÓN" />
            <div class="menu__info">
              <h3 class="card__title">DOLO-NEUROBIÓN N TABLETAS</h3>
              <p class="card__text">Se usa para aliviar el dolor e inflamación asociados a problemas musculares...</p>
              <div class="cart__price">
                <p class="price">₡1.500</p>
                <i class="fa-solid fa-cart-plus"></i>
              </div>
            </div>
          </div>

        </div>


        <!-- Sucursales -->
        <section class="booking">
          <div class="booking__container">
            <h2 class="booking__title">Encuentra lo que necesitas</h2>
            <p class="booking__text">
              Visitá cualquiera de nuestras 3 sucursales para adquirir tus medicamentos... <span>Elegí la sede de tu
                interés.</span>
            </p>
            <div class="booking__places">
              <button class="btn btn__place"><i class="fa-solid fa-location-dot"></i> Norte</button>
              <button class="btn btn__place"><i class="fa-solid fa-location-dot"></i> Centro</button>
              <button class="btn btn__place"><i class="fa-solid fa-location-dot"></i> Sur</button>
            </div>
          </div>
        </section>

        <!-- Enfermedades - Estilo Aporte JD -->
        <section class="Enfermedades">
          <h2 class="titulo-enfermedades">Enfermedades actuales</h2>
          <div class="wrapper">
            <div class="container-cartas">
              <input type="radio" name="slide" id="c1" checked>
              <label for="c1" class="card-info virus">
                <div class="vertical-title">Virus</div>
                <div class="row">
                  <div class="icon">1</div>
                  <div class="description">
                    <h4>Virus</h4>
                    <p>¿Hay riesgo de pandemia por gripe aviar en 2025?</p>
                  </div>
                </div>
              </label>

              <input type="radio" name="slide" id="c2">
              <label for="c2" class="card-info coronavirus">
                <div class="vertical-title">Coronavirus</div>
                <div class="row">
                  <div class="icon">2</div>
                  <div class="description">
                    <h4>Coronavirus</h4>
                    <p>¿Habrá una pandemia en 2025?</p>
                  </div>
                </div>
              </label>

              <input type="radio" name="slide" id="c3">
              <label for="c3" class="card-info fiebre">
                <div class="vertical-title">Fiebre</div>
                <div class="row">
                  <div class="icon">3</div>
                  <div class="description">
                    <h4>Fiebre Amarilla</h4>
                    <p>OPS emite nueva alerta por fiebre amarilla</p>
                  </div>
                </div>
              </label>
            </div>
          </div>
        </section>

  </main>

  <?php

  verfooter();
  ?>

  <?php
  añadirScripts(); // Todos los scripts JS 
  ?>

</body>

</html>