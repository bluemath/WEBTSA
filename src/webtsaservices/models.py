from __future__ import unicode_literals
from django.db import models
from django.core.validators import RegexValidator
import re

# class DataSeriesField(models.Model):
#     fieldname = models.CharField(db_column='FieldName', max_length=128, primary_key=True)
#
#     class Meta:
#         managed = False
#         db_table = 'DataSeriesFields'


class SearchFacet(models.Model):
    name = models.CharField(max_length=255)
    keyfield = models.CharField(max_length=128)
    namefields = models.CharField(max_length=128, validators=[
        RegexValidator(
            regex=re.compile(r"^\w+(,\w+)*$"),
            message=u'Value must be a comma separated value.',
            code='invalid_values'
        ),
    ])
    selected = models.CharField(max_length=255, null=True, blank=True)

    def __unicode__(self):
        return self.name


class SourcesDataService(models.Model):
    sourcedataserviceid = models.IntegerField(db_column='SourceDataServiceID', primary_key=True)
    servicename = models.CharField(db_column='ServiceName', max_length=255)
    servicedescription = models.CharField(db_column='ServiceDescription', max_length=500)
    serviceurl = models.CharField(db_column='ServiceURL', max_length=500)
    sourcenetworkname = models.CharField(db_column='SourceNetworkName', max_length=255, null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'SourceDataServices'


class DataSeries(models.Model):
    seriesid = models.IntegerField(db_column='SeriesID', primary_key=True)
    sourcedataserviceid = models.IntegerField(db_column='SourceDataServiceID')
    network = models.CharField(db_column='Network', max_length=50)
    sitecode = models.CharField(db_column='SiteCode', max_length=50)
    sitename = models.CharField(db_column='SiteName', max_length=500)
    latitude = models.FloatField(db_column='Latitude', null=True, blank=True)
    longitude = models.FloatField(db_column='Longitude', null=True, blank=True)
    state = models.CharField(db_column='State', max_length=50, null=True, blank=True)
    county = models.CharField(db_column='County', max_length=50, null=True, blank=True)
    sitetype = models.CharField(db_column='SiteType', max_length=50)
    variablecode = models.CharField(db_column='VariableCode', max_length=50)
    variablename = models.CharField(db_column='VariableName', max_length=255)
    variablelevel = models.CharField(db_column='VariableLevel', max_length=50)
    methoddescription = models.CharField(db_column='MethodDescription', max_length=500)
    variableunitsname = models.CharField(db_column='VariableUnitsName', max_length=255, null=True, blank=True)
    variableunitstype = models.CharField(db_column='VariableUnitsType', max_length=50, null=True, blank=True)
    variableunitsabbreviation = models.CharField(db_column='VariableUnitsAbbreviation', max_length=50)
    samplemedium = models.CharField(db_column='SampleMedium', max_length=50)
    valuetype = models.CharField(db_column='ValueType', max_length=50, null=True, blank=True)
    datatype = models.CharField(db_column='DataType', max_length=50, null=True, blank=True)
    generalcategory = models.CharField(db_column='GeneralCategory', max_length=50, null=True, blank=True)
    timesupport = models.FloatField(db_column='TimeSupport', null=True, blank=True)
    timesupportunitsname = models.CharField(db_column='TimeSupportUnitsName', max_length=500, null=True, blank=True)
    timesupportunitstype = models.CharField(db_column='TimeSupportUnitsType', max_length=50, null=True, blank=True)
    timesupportunitsabbreviation = models.CharField(db_column='TimeSupportUnitsAbbreviation', max_length=50, null=True, blank=True)
    qualitycontrollevelcode = models.CharField(db_column='QualityControlLevelCode', max_length=50, null=True, blank=True)
    qualitycontrolleveldefinition = models.CharField(db_column='QualityControlLevelDefinition', max_length=500)
    qualitycontrollevelexplanation = models.CharField(db_column='QualityControlLevelExplanation', max_length=500, null=True, blank=True)
    sourceorganization = models.CharField(db_column='SourceOrganization', max_length=255)
    sourcedescription = models.CharField(db_column='SourceDescription', max_length=500)
    begindatetime = models.DateTimeField(db_column='BeginDateTime')
    enddatetime = models.DateTimeField(db_column='EndDateTime')
    utcoffset = models.IntegerField(db_column='UTCOffset', null=True, blank=True)
    numberobservations = models.IntegerField(db_column='NumberObservations')
    datelastupdated = models.DateTimeField(db_column='DateLastUpdated')
    isactive = models.BigIntegerField(db_column='IsActive')
    getdataurl = models.CharField(db_column='GetDataURL', max_length=500)

    class Meta:
        managed = False
        db_table = 'DataSeries'


class Site(models.Model):
    sourcedataserviceid = models.IntegerField(db_column='SourceDataServiceID')
    network = models.CharField(db_column='Network', max_length=50)
    sitecode = models.CharField(db_column='SiteCode', max_length=50, primary_key=True)
    sitename = models.CharField(db_column='SiteName', max_length=500)
    latitude = models.FloatField(db_column='Latitude', null=True, blank=True)
    longitude = models.FloatField(db_column='Longitude', null=True, blank=True)
    state = models.CharField(db_column='State', max_length=50, null=True, blank=True)
    county = models.CharField(db_column='County', max_length=50, null=True, blank=True)
    sitetype = models.CharField(db_column='SiteType', max_length=50)

    class Meta:
        managed = False
        db_table = 'Sites'


class VariableCategory(models.Model):
    generalcategory = models.CharField(db_column='GeneralCategory', max_length=50, null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'VariableCategories'


class Variable(models.Model):
    variablecode = models.CharField(db_column='VariableCode', max_length=50)
    variablename = models.CharField(db_column='VariableName', max_length=255)

    class Meta:
        managed = False
        db_table = 'Variable'


class QualityControlLevel(models.Model):
    code = models.CharField(db_column='QualityControlLevelCode', max_length=50, null=True, blank=True)
    definition = models.CharField(db_column='QualityControlLevelDefinition', max_length=500)
    explanation = models.CharField(db_column='QualityControlLevelExplanation', max_length=500, null=True, blank=True)

    class Meta:
        managed = False
        db_table = 'QualityControlLevels'
