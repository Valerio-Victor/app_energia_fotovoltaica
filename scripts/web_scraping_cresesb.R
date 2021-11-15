


library(magrittr, include.only = '%>%')


# Definição da URL base de requisição:
url_base <- 'http://www.cresesb.cepel.br/index.php'


# Definição da latitude e da longitude para definição do município:
lat <- 16.6799
lng <- 49.255


# Parâmetros da requisição post com referência a latitude e longitude:
parametros <- list(latitude_dec = lat,
                   latitude = -lat,
                   hemi_lat = 0,
                   longitude_dec = lng,
                   longitude = -lng,
                   formato = 1,
                   lang = 'pt',
                   section = 'sundata')


# Requisição da Página (com impressão do html na pasta0):
pagina <- httr::POST(url_base,
                     body = parametros,
                     httr::write_disk('./html/crescesb.html',
                                      overwrite = TRUE))


# Definição do XML path para as tabelas com os dados de recurso solar:
tab_sundata <- '//*[@class="tb_sundata"]'


# Arrumação dos dados para organização da tabela:
crescesb <- xml2::read_html('./html/crescesb.html') %>%
  xml2::xml_find_first(tab_sundata) %>%
  rvest::html_table() %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::select(!number)


nomes <- crescesb[1, ]
colnames(crescesb) <- nomes


crescesb <- crescesb %>%
  janitor::clean_names() %>%
  dplyr::select(!c(na, na_2)) %>%
  dplyr::filter(angulo != 'Ângulo') %>%
  tibble::view()

#-------------------------------------------------------------------------------


municipios <- readxl::read_xlsx('./xlsx/dados_municipios.xlsx') %>%
  dplyr::select(codigo_ibge, nome, latitude, longitude) %>%
  dplyr::mutate(recurso_solar = NA)


for (i in 1:nrow(municipios)) {

lat <- as.numeric(-municipios[i,3])
lng <- as.numeric(-municipios[i,4])


# Definição da URL base de requisição:
url_base <- 'http://www.cresesb.cepel.br/index.php'


# Parâmetros da requisição post com referência a latitude e longitude:
parametros <- list(latitude_dec = lat,
                   latitude = -lat,
                   hemi_lat = 0,
                   longitude_dec = lng,
                   longitude = -lng,
                   formato = 1,
                   lang = 'pt',
                   section = 'sundata')


# Requisição da Página (com impressão do html na pasta0):
pagina <- httr::POST(url_base,
                     body = parametros,
                     httr::write_disk('./html/crescesb.html',
                                      overwrite = TRUE))


# Definição do XML path para as tabelas com os dados de recurso solar:
tab_sundata <- '//*[@class="tb_sundata"]'


# Arrumação dos dados para organização da tabela:
crescesb <- xml2::read_html('./html/crescesb.html') %>%
  xml2::xml_find_first(tab_sundata) %>%
  rvest::html_table() %>%
  janitor::clean_names() %>%
  tibble::as_tibble() %>%
  dplyr::select(!number)


nomes <- crescesb[1, ]
colnames(crescesb) <- nomes


crescesb <- crescesb %>%
  janitor::clean_names() %>%
  dplyr::select(!c(na, na_2)) %>%
  dplyr::filter(angulo != 'Ângulo') %>%
  tibble::as_tibble()


# Criando o data frame complexo com listas
municipios$recurso_solar[i] <- list(crescesb)


}


municipios_tbl <- municipios %>%
  tidyr::unnest(recurso_solar)


writexl::write_xlsx(municipios_tbl, './xlsx/recurso_solar_municipios.xlsx')
saveRDS(municipios, 'recurso_solar_municipios.rds')


