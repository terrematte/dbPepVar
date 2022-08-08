# get shiny serves plus tidyverse packages image
FROM rocker/shiny-verse:latest
# system libraries of general use
RUN apt-get update && apt-get install -y \
    sudo \
    pandoc \
    pandoc-citeproc \
    libcurl4-gnutls-dev \
    libcairo2-dev \
    libxt-dev \
    libssl-dev \
    libssh2-1-dev 
# install R packages required 
RUN R -e "install.packages('dplyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('DT', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('forcats', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('ggplot2', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('knitr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('plotly', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shiny', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('stringr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('tidyr', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('vctrs', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('vroom', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('waiter', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('cicerone', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('shinycssloaders', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('digest', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('memoise', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('htmltools', repos='http://cran.rstudio.com/')"
RUN R -e "install.packages('cachem', repos='http://cran.rstudio.com/')"
# copy the app to the image
COPY dbPepVar.Rproj /srv/dbPepVar/dbPepVar.Rproj
COPY global.R /srv/dbPepVar/global.R
COPY server.R /srv/dbPepVar/server.R
COPY ui.R /srv/dbPepVar/ui.R
COPY run.R /srv/dbPepVar/run.R
COPY doc /srv/dbPepVar/doc
COPY data /srv/dbPepVar/data
COPY icons /srv/dbPepVar/icons
COPY www /srv/dbPepVar/www
COPY R /srv/dbPepVar/R
COPY README.md /srv/dbPepVar/README.md
# select port
EXPOSE 3838
# allow permission
RUN sudo chown -R shiny:shiny /srv/dbPepVar
# run app
CMD ["R", "-e", "shiny::runApp('/srv/dbPepVar', host='0.0.0.0', port=3838)"]
