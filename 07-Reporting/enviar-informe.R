
# Establecemos el directori de trabajo ------------------------------------

setwd("~/Documents/GitHub/kschool_r/07-Reporting")


# Generamos el informe ----------------------------------------------------

if (!require("rmarkdown")) install.packages("rmarkdown")
library(rmarkdown)
rmarkdown::render("sesiones.Rmd", 'html_document', output_dir=".", output_file="sesiones.html")


# Envío por correo --------------------------------------------------------

# Clave de acceso a Gmail
use_secret_file("ks-alumnos-gmail.json")

# La primera vez 
# gmail_auth()

body_text <- "<h1>Informe de sesiones</h1><p>Previsión de tráfico para los próximos 6 meses.</p><p>Un saludo.</p>"


html_msg <- mime() %>%
  to("jose@elartedemedir.com") %>%
  from("kschool.alumnos@gmail.com") %>%
  subject("Tienes un nuevo informe de tráfico") %>%
  html_body(body_text) %>%
  attach_part(body_text, content_type = "text/html") %>%
  attach_file("sesiones.xlsx") %>% 
  attach_file("sesiones.html")-> file_attachment

# Creadmos el borrados
draft <- create_draft(file_attachment)

# Enviamos el mail
send_draft(draft)
