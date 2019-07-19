#include "a2l.h"	
#include <stdio.h>
#include <stdlib.h>

/***** AXIS_DESCR ******/

/****** CHARACTERISTIC ******/
Characteristic * CreateCharacteristic() {
	Characteristic *characteristic = malloc(sizeof(Characteristic));
	characteristic->nAxisDescr = 0;
	return characteristic;
}

void SetAxisDescr(Characteristic *characteristic, Axis_Descr *ActiveAxisDescr) {
	if (characteristic->nAxisDescr == MAX_AXIS_DESCR) {
		perror("Number of axis_descr in characteristic exceeds allotted amount");
	}
	int nAxisDescr = characteristic->nAxisDescr;
	characteristic->aAxisDescr[nAxisDescr] = ActiveAxisDescr;
	characteristic->nAxisDescr++;
	ActiveAxisDescr = NULL;
}

/****** MEASUREMENT ******/
Measurement * CreateMeasurement() {
	return malloc(sizeof(Measurement));
}

/****** MODULE ******/
Module * CreateModule() {
	Module *module = malloc(sizeof(Module));
	module->nCharacteristics = 0;
	module->nMeasurements = 0;
	module->nAxisPts = 0;
	return module;
};

void SetCharacteristic(Module *module, Characteristic *ActiveCharacteristic) {
	if (module->nCharacteristics == MAX_CHARACTERISTICS) {
		perror("Number of characteristics in module exceeds allotted amount");
	}
	int nCharacteristics = module->nCharacteristics;
	module->aCharacteristics[nCharacteristics] = ActiveCharacteristic;
	module->nCharacteristics++;
	ActiveCharacteristic = NULL;
}

void SetMeasurement(Module *module, Measurement *ActiveMeasurement) {
	if (module->nMeasurements == MAX_MEASUREMENTS) {
		perror("Number of measurements in module exceeds allotted amount");
	}
	int nMeasurements = module->nMeasurements;
	module->aMeasurements[nMeasurements] = ActiveMeasurement;
	module->nMeasurements++;
	ActiveMeasurement = NULL;
}

/****** PROJECT ******/
void SetModule(Project *project, Module *ActiveModule) {
	if (project->nModules == MAX_MODULES) {
  		perror("Number of modules in project exceeds allotted amount");
  	}
  	project->aModules[project->nModules] = ActiveModule;
  	project->nModules++; /* Increment number of modules in project */
  	ActiveModule = NULL;
};

/* Free Project */
void FreeProject(Project *project) {
	Module * module;
	Characteristic * characteristic;
	for (int i=0; i<project->nModules; i++) {
		module = project->aModules[i];
		for (int j=0; j<module->nCharacteristics; j++) {
			characteristic = module->aCharacteristics[j];
			for (int k=0; k < characteristic->nAxisDescr; k++) {
				free(characteristic->aAxisDescr[k]);
			}
			free(characteristic);
		}
		for (int j=0; j<module->nMeasurements; j++) {
			free(module->aMeasurements[j]);
		}
		free(module);
	}
	/* Reset Project */
	*project = reset_project; /* Null Project */
}