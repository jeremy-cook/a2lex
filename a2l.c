#include "a2l.h"	
#include <stdio.h>
#include <stdlib.h>

/***** AXIS_DESCR ******/

/****** CHARACTERISTIC ******/
int nAxisDescr = 0;

Characteristic * CreateCharacteristic() {
	nAxisDescr = 0;
	return malloc(sizeof(Characteristic));
}

void SetAxisDescr(Characteristic *characteristic, Axis_Descr *ActiveAxisDescr) {
	if (nAxisDescr == MAX_AXIS_DESCR) {
		perror("Number of axis_descr in characteristic exceeds allotted amount");
	}
	characteristic->aAxisDescr[nAxisDescr] = ActiveAxisDescr;
	ActiveAxisDescr = NULL;
}

/****** MEASUREMENT ******/
Measurement * CreateMeasurement() {
	return malloc(sizeof(Measurement));
}

/****** MODULE ******/
int nCharacteristics = 0;
int nMeasurements = 0;
int nAxisPts = 0;

Module * CreateModule() {
	nCharacteristics = 0;
	nMeasurements = 0;
	nAxisPts = 0;
	return malloc(sizeof(Module));
};

void SetCharacteristic(Module *module, Characteristic *ActiveCharacteristic) {
	if (nCharacteristics == MAX_CHARACTERISTICS) {
		perror("Number of characteristics in module exceeds allotted amount");
	}
	module->aCharacteristics[nCharacteristics] = ActiveCharacteristic;
	nCharacteristics++;
	ActiveCharacteristic = NULL;
}

void SetMeasurement(Module *module, Measurement *ActiveMeasurement) {
	if (nMeasurements == MAX_MEASUREMENTS) {
		perror("Number of measurements in module exceeds allotted amount");
	}
	module->aMeasurements[nMeasurements] = ActiveMeasurement;
	nMeasurements++;
	ActiveMeasurement = NULL;
}

/****** PROJECT ******/
int nModules = 0;

void SetModule(Project *project, Module *ActiveModule) {
	if (nModules == MAX_MODULES) {
  		perror("Number of modules in project exceeds allotted amount");
  	}
  	project->aModules[nModules] = ActiveModule;
  	nModules++; /* Increment number of modules in project */
  	ActiveModule = NULL;
};