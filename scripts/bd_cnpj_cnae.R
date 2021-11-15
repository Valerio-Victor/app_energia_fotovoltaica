


library(magrittr, include.only = '%>%')



# Identificação do projeto do google cloud:
basedosdados::set_billing_id('energiafotovoltaica')



# Identificação da base na base dos dados:
base <- 'br_me_socios.cnae_cnpj'



# Importando o "espelho da tabela" de dados:
cnpj_cnae <- basedosdados::bdplyr(base)



# Entendendo a estrutura dos dados e arrumação para importação:
tibble::glimpse(cnpj_cnae)

dplyr::show_query(cnpj_cnae)

cnpj_cnae <- cnpj_cnae %>%
  dplyr::select(!primaria)



# Importação dos dados já arrumados:
cnpj_cnae <- basedosdados::bd_collect(cnpj_cnae)



# Importação dos dados já arrumados:
dados <- readr::read_csv2('cnpj_cnae.csv')

