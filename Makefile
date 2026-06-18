data/processed/football_games.csv: 01_get_schedules.R
	Rscript 01_get_schedules.R

data/processed/crime_daily.csv \
data/processed/crimes_2000.csv \
data/processed/crimes_2001.csv \
data/processed/crimes_2002.csv \
data/processed/crimes_2003.csv \
data/processed/crimes_2004.csv \
data/processed/crimes_2005.csv: \
	data/nibrs/nibrs_offense_segment_2000.csv \
	data/nibrs/nibrs_offense_segment_2001.csv \
	data/nibrs/nibrs_offense_segment_2002.csv \
	data/nibrs/nibrs_offense_segment_2003.csv \
	data/nibrs/nibrs_offense_segment_2004.csv \
	data/nibrs/nibrs_offense_segment_2005.csv \
	02_filter_nibrs.R
	Rscript 02_filter_nibrs.R

data/processed/team_agency_candidates.csv: \
	data/nibrs/nibrs_batch_header_1991_2024.csv \
	03_build_team_agency_mapping.R
	Rscript 03_build_team_agency_mapping.R

data/processed/analysis_data.csv: \
	data/processed/crime_daily.csv \
	data/processed/football_games.csv \
	data/processed/team_agency_mapping.csv \
	04_create_analysis_data.R
	Rscript 04_create_analysis_data.R

results.html: data/processed/analysis_data.csv results.Rmd
	Rscript -e "rmarkdown::render('results.Rmd')"