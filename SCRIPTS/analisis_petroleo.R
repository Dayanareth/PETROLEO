library(readxl)
library(fpp3)
library(tidyverse)
library(here)

# 1. Importar
base <- read_xlsx(here("DATA", "Datos_petroleo.xlsx"))

# 2. Convertir a data frame
base <- as.data.frame(base)
class(base)

names(base) <- c("fecha", "precio_cierre", "apertura", "maximo",
                 "minimo", "volumen", "var_pct")

# 3. Limpieza
base_t <- base |>
  mutate(
    fecha = ymd(fecha),
    multiplicador = case_when(
      str_detect(volumen, "K$") ~ 1e3,
      str_detect(volumen, "M$") ~ 1e6
    ),
    volumen = parse_number(volumen, locale = locale(decimal_mark = ",")) * multiplicador
  ) |>
  select(-multiplicador) |>
  arrange(fecha)   # el Excel viene en orden descendente

head(base_t)

# 4. Convertir a tsibble
base_nueva <- base_t |>
  as_tsibble(index = fecha)

head(base_nueva)

# 5. Revisar huecos (fines de semana y feriados)
count_gaps(base_nueva)
