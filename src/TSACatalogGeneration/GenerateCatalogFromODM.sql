USE [TSA_Catalog]
GO
/****** Object:  StoredProcedure [dbo].[spUpdateTSA_CatalogDataSeries]    Script Date: 1/23/2015 2:35:10 PM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Amber Jones
-- Create date: 09-26-2014
-- Modified:  
-- Description:	Clears the GAMUT Data in the DataSeries
-- catalog table and regnerates the GAMUT Data in the table.
-- =============================================

ALTER PROCEDURE [dbo].[spUpdateTSA_CatalogDataSeries] AS

--Clear out the GAMUT Data from the DataSeries Table
DELETE FROM [TSA_Catalog].[Catalog].[DataSeries] WHERE SourceDataServiceID IN (1,2,3,7)

--Reset the primary key field. 
--NOTE: The series starts at the last USGS Data Series (220).
DBCC CHECKIDENT ([TSA_Catalog.Catalog.DataSeries], RESEED, 220)

--Recreate the GAMUT records in the DataSeries Table using a separate insert statement for each watershed/database.

--Query Red Butte Creek data from iUTAH_RedButte_OD

INSERT INTO [TSA_Catalog].[Catalog].[DataSeries] (SourceDataServiceID, Network, SiteCode, SiteName, Latitude, Longitude, State, County, SiteType, 
	VariableCode, VariableName, VariableLevel, MethodDescription, VariableUnitsName, VariableUnitsType, VariableUnitsAbbreviation, SampleMedium, 
	ValueType, DataType, GeneralCategory, TimeSupport, TimeSupportUnitsName, TimeSupportUnitsType, TimeSupportUnitsAbbreviation, 
	QualityControlLevelCode, QualityControlLevelDefinition, QualityControlLevelExplanation, SourceOrganization, SourceDescription, 
	BeginDateTime, EndDateTime, UTCOffset, NumberObservations, DateLastUpdated, IsActive, GetDataURL)
SELECT 1 AS SourceDataServiceID, 'Red Butte Creek' AS Network, sc.SiteCode, sc.SiteName, s.Latitude, s.Longitude, s.State, s.County, s.SiteType, 
	v.VariableCode, v.VariableName, vl.VariableLevel, sc.MethodDescription, 
	uv.UnitsName AS VariableUnitsName, uv.UnitsType AS VariableUnitsType, uv.UnitsAbbreviation AS VariableUnitsAbbreviation,
	v.SampleMedium, v.ValueType, v.DataType, v.GeneralCategory, v.TimeSupport, 
	ut.UnitsName AS TimeSupportUnitsName, ut.UnitsType AS TimeSupportUnitsType, ut.UnitsAbbreviation AS TimeSupportUnitsAbbreviation, 
	qc.QualityControlLevelCode, qc.Definition AS QualityControlLevelDefinition, qc.Explanation AS QualityControlLevelExplanation, 
	sc.Organization AS SourceOrganization, sc.SourceDescription, 
	sc.BeginDateTime, sc.EndDateTime, DATEDIFF(hh,sc.BeginDateTimeUTC,sc.BeginDateTime) AS UTCOffset, 
	sc.ValueCount AS NumberObservations, sc.EndDateTime AS DateLastUpdated, 1 AS IsActive,
	('http://data.iutahepscor.org/RedButteCreekWOF/REST/waterml_1_1.svc/datavalues?' + 
	'location=iutah:' + sc.SiteCode + '&variable=iutah:' + sc.VariableCode + '/methodCode=' + CAST(sc.MethodID AS varchar(15)) + 
	'/sourceCode=' + CAST(sc.SourceID AS varchar(15)) + '/qualityControlLevelCode=' + CAST(sc.QualityControlLevelID AS varchar(15)) + 
	'&startDate=&endDate=') AS GetDataURL  
FROM [iUTAH_RedButte_OD].dbo.[SeriesCatalog] AS sc
JOIN [iUTAH_RedButte_OD].dbo.[Variables] AS v
ON sc.VariableID = v.VariableID
JOIN [TSA_Catalog].dbo.[CommonVariableLookup] AS vl
ON v.VariableCode = vl.VariableCode
JOIN [iUTAH_RedButte_OD].dbo.[Sites] AS s
ON sc.SiteID = s.SiteID
JOIN [iUTAH_RedButte_OD].dbo.[Units] AS uv
ON sc.VariableUnitsID = uv.UnitsID
JOIN [iUTAH_RedButte_OD].dbo.[Units] AS ut
ON sc.TimeUnitsID = ut.UnitsID
JOIN [iUTAH_RedButte_OD].dbo.[QualityControlLevels] AS qc
ON sc.QualityControlLevelID = qc.QualityControlLevelID
ORDER BY SiteCode, VariableCode

--Query Logan River data from iUTAH_Logan_OD

INSERT INTO [TSA_Catalog].[Catalog].[DataSeries] (SourceDataServiceID, Network, SiteCode, SiteName, Latitude, Longitude, State, County, SiteType, 
	VariableCode, VariableName, VariableLevel, MethodDescription, VariableUnitsName, VariableUnitsType, VariableUnitsAbbreviation, SampleMedium, 
	ValueType, DataType, GeneralCategory, TimeSupport, TimeSupportUnitsName, TimeSupportUnitsType, TimeSupportUnitsAbbreviation, 
	QualityControlLevelCode, QualityControlLevelDefinition, QualityControlLevelExplanation, SourceOrganization, SourceDescription, 
	BeginDateTime, EndDateTime, UTCOffset, NumberObservations, DateLastUpdated, IsActive, GetDataURL)
SELECT 2 AS SourceDataServiceID, 'Logan River' AS Network, sc.SiteCode, sc.SiteName, s.Latitude, s.Longitude, s.State, s.County, s.SiteType, 
	v.VariableCode, v.VariableName, vl.VariableLevel, sc.MethodDescription, 
	uv.UnitsName AS VariableUnitsName, uv.UnitsType AS VariableUnitsType, uv.UnitsAbbreviation AS VariableUnitsAbbreviation,
	v.SampleMedium, v.ValueType, v.DataType, v.GeneralCategory, v.TimeSupport, 
	ut.UnitsName AS TimeSupportUnitsName, ut.UnitsType AS TimeSupportUnitsType, ut.UnitsAbbreviation AS TimeSupportUnitsAbbreviation, 
	qc.QualityControlLevelCode, qc.Definition AS QualityControlLevelDefinition, qc.Explanation AS QualityControlLevelExplanation, 
	sc.Organization AS SourceOrganization, sc.SourceDescription, 
	sc.BeginDateTime, sc.EndDateTime, DATEDIFF(hh,sc.BeginDateTimeUTC,sc.BeginDateTime) AS UTCOffset, 
	sc.ValueCount AS NumberObservations, sc.EndDateTime AS DateLastUpdated, 1 AS IsActive,
	('http://data.iutahepscor.org/LoganRiverWOF/REST/waterml_1_1.svc/datavalues?' + 
	'location=iutah:' + sc.SiteCode + '&variable=iutah:' + sc.VariableCode + '/methodCode=' + CAST(sc.MethodID AS varchar(15)) + 
	'/sourceCode=' + CAST(sc.SourceID AS varchar(15)) + '/qualityControlLevelCode=' + CAST(sc.QualityControlLevelID AS varchar(15)) + 
	'&startDate=&endDate=') AS GetDataURL  
FROM [iUTAH_Logan_OD].dbo.[SeriesCatalog] AS sc
JOIN [iUTAH_Logan_OD].dbo.[Variables] AS v
ON sc.VariableID = v.VariableID
JOIN [TSA_Catalog].dbo.[CommonVariableLookup] AS vl
ON v.VariableCode = vl.VariableCode
JOIN [iUTAH_Logan_OD].dbo.[Sites] AS s
ON sc.SiteID = s.SiteID
JOIN [iUTAH_Logan_OD].dbo.[Units] AS uv
ON sc.VariableUnitsID = uv.UnitsID
JOIN [iUTAH_Logan_OD].dbo.[Units] AS ut
ON sc.TimeUnitsID = ut.UnitsID
JOIN [iUTAH_Logan_OD].dbo.[QualityControlLevels] AS qc
ON sc.QualityControlLevelID = qc.QualityControlLevelID
ORDER BY SiteCode, VariableCode

--Query Provo River data from iUTAH_Provo_OD

INSERT INTO [TSA_Catalog].[Catalog].[DataSeries] (SourceDataServiceID, Network, SiteCode, SiteName, Latitude, Longitude, State, County, SiteType, 
	VariableCode, VariableName, VariableLevel, MethodDescription, VariableUnitsName, VariableUnitsType, VariableUnitsAbbreviation, SampleMedium, 
	ValueType, DataType, GeneralCategory, TimeSupport, TimeSupportUnitsName, TimeSupportUnitsType, TimeSupportUnitsAbbreviation, 
	QualityControlLevelCode, QualityControlLevelDefinition, QualityControlLevelExplanation, SourceOrganization, SourceDescription, 
	BeginDateTime, EndDateTime, UTCOffset, NumberObservations, DateLastUpdated, IsActive, GetDataURL)
SELECT 3 AS SourceDataServiceID, 'Provo River' AS Network, sc.SiteCode, sc.SiteName, s.Latitude, s.Longitude, s.State, s.County, s.SiteType, 
	v.VariableCode, v.VariableName, vl.VariableLevel, sc.MethodDescription, 
	uv.UnitsName AS VariableUnitsName, uv.UnitsType AS VariableUnitsType, uv.UnitsAbbreviation AS VariableUnitsAbbreviation,
	v.SampleMedium, v.ValueType, v.DataType, v.GeneralCategory, v.TimeSupport, 
	ut.UnitsName AS TimeSupportUnitsName, ut.UnitsType AS TimeSupportUnitsType, ut.UnitsAbbreviation AS TimeSupportUnitsAbbreviation, 
	qc.QualityControlLevelCode, qc.Definition AS QualityControlLevelDefinition, qc.Explanation AS QualityControlLevelExplanation, 
	sc.Organization AS SourceOrganization, sc.SourceDescription, 
	sc.BeginDateTime, sc.EndDateTime, DATEDIFF(hh,sc.BeginDateTimeUTC,sc.BeginDateTime) AS UTCOffset, 
	sc.ValueCount AS NumberObservations, sc.EndDateTime AS DateLastUpdated, 1 AS IsActive,
	('http://data.iutahepscor.org/ProvoRiverWOF/REST/waterml_1_1.svc/datavalues?' + 
	'location=iutah:' + sc.SiteCode + '&variable=iutah:' + sc.VariableCode + '/methodCode=' + CAST(sc.MethodID AS varchar(15)) + 
	'/sourceCode=' + CAST(sc.SourceID AS varchar(15)) + '/qualityControlLevelCode=' + CAST(sc.QualityControlLevelID AS varchar(15)) + 
	'&startDate=&endDate=') AS GetDataURL  
FROM [iUTAH_Provo_OD].dbo.[SeriesCatalog] AS sc
JOIN [iUTAH_Provo_OD].dbo.[Variables] AS v
ON sc.VariableID = v.VariableID
JOIN [TSA_Catalog].dbo.[CommonVariableLookup] AS vl
ON v.VariableCode = vl.VariableCode
JOIN [iUTAH_Provo_OD].dbo.[Sites] AS s
ON sc.SiteID = s.SiteID
JOIN [iUTAH_Provo_OD].dbo.[Units] AS uv
ON sc.VariableUnitsID = uv.UnitsID
JOIN [iUTAH_Provo_OD].dbo.[Units] AS ut
ON sc.TimeUnitsID = ut.UnitsID
JOIN [iUTAH_Provo_OD].dbo.[QualityControlLevels] AS qc
ON sc.QualityControlLevelID = qc.QualityControlLevelID
ORDER BY SiteCode, VariableCode

--Query Green Meadows data from GreenMeadowsOD

INSERT INTO [TSA_Catalog].[Catalog].[DataSeries] (SourceDataServiceID, Network, SiteCode, SiteName, Latitude, Longitude, State, County, SiteType, 
	VariableCode, VariableName, VariableLevel, MethodDescription, VariableUnitsName, VariableUnitsType, VariableUnitsAbbreviation, SampleMedium, 
	ValueType, DataType, GeneralCategory, TimeSupport, TimeSupportUnitsName, TimeSupportUnitsType, TimeSupportUnitsAbbreviation, 
	QualityControlLevelCode, QualityControlLevelDefinition, QualityControlLevelExplanation, SourceOrganization, SourceDescription, 
	BeginDateTime, EndDateTime, UTCOffset, NumberObservations, DateLastUpdated, IsActive, GetDataURL)
SELECT 7 AS SourceDataServiceID, 'Green Infrastructure Research' AS Network, sc.SiteCode, sc.SiteName, s.Latitude, s.Longitude, s.State, s.County, 'Other' AS SiteType, 
	v.VariableCode, v.VariableName, vl.VariableLevel, sc.MethodDescription, 
	uv.UnitsName AS VariableUnitsName, uv.UnitsType AS VariableUnitsType, uv.UnitsAbbreviation AS VariableUnitsAbbreviation,
	v.SampleMedium, v.ValueType, v.DataType, v.GeneralCategory, v.TimeSupport, 
	ut.UnitsName AS TimeSupportUnitsName, ut.UnitsType AS TimeSupportUnitsType, ut.UnitsAbbreviation AS TimeSupportUnitsAbbreviation, 
	qc.QualityControlLevelCode, qc.Definition AS QualityControlLevelDefinition, qc.Explanation AS QualityControlLevelExplanation, 
	sc.Organization AS SourceOrganization, sc.SourceDescription, 
	sc.BeginDateTime, sc.EndDateTime, DATEDIFF(hh,sc.BeginDateTimeUTC,sc.BeginDateTime) AS UTCOffset, 
	sc.ValueCount AS NumberObservations, sc.EndDateTime AS DateLastUpdated, 1 AS IsActive,
	('http://data.iutahepscor.org/greenmeadows/REST/waterml_1_1.svc/datavalues?' + 
	'location=iutah:' + sc.SiteCode + '&variable=iutah:' + sc.VariableCode + '/methodCode=' + CAST(sc.MethodID AS varchar(15)) + 
	'/sourceCode=' + CAST(sc.SourceID AS varchar(15)) + '/qualityControlLevelCode=' + CAST(sc.QualityControlLevelID AS varchar(15)) + 
	'&startDate=&endDate=') AS GetDataURL  
FROM [GreenMeadowsOD].dbo.[SeriesCatalog] AS sc
JOIN [GreenMeadowsOD].dbo.[Variables] AS v
ON sc.VariableID = v.VariableID
JOIN [TSA_Catalog].dbo.[CommonVariableLookup] AS vl
ON v.VariableCode = vl.VariableCode
JOIN [GreenMeadowsOD].dbo.[Sites] AS s
ON sc.SiteID = s.SiteID
JOIN [GreenMeadowsOD].dbo.[Units] AS uv
ON sc.VariableUnitsID = uv.UnitsID
JOIN [GreenMeadowsOD].dbo.[Units] AS ut
ON sc.TimeUnitsID = ut.UnitsID
JOIN [GreenMeadowsOD].dbo.[QualityControlLevels] AS qc
ON sc.QualityControlLevelID = qc.QualityControlLevelID
ORDER BY SiteCode, VariableCode





