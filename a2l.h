/* Includes */
#include <stdlib.h>

/* Defines */
#define MAX_AXIS_PTS 10000
#define MAX_CHARACTERISTICS 30000
#define MAX_MEASUREMENTS 50000
#define MAX_MODULES 2
#define MAX_AXIS_DESCR 4

/* Utilities */

/******* Start Structure Definitions *******/
	enum _Monotony {
		MON_DECREASE,
		MON_INCREASE,
		STRICT_DECREASE,
		STRICT_INCREASE,
		MONOTONOUS,
		STRICT_MON,
		NOT_MON
	};

	typedef struct Axis_Pts {
		char *Name;
		char *Id;
		unsigned long Address;
		char *InputQuantity;
		char *Deposit;
		float MaxDiff;
		char *Conversion;
		unsigned int MaxAxisPoints;
		float LowerLimit;
		float UpperLimit;
		char *Annotation;
		char *Format;
		enum _Monotony Monotony;
		char *Unit;
	} Axis_Pts;

/*************** START AXIS DESCRIPTION **************/
	
	enum _Attribute {
		CURVE_AXIS,
		COM_AXIS,
		FIX_AXIS,
		RES_AXIS,
		STD_AXIS
	};
	
	typedef struct Axis_Descr {
		enum _Attribute Attribute;
		char *InputQuantity;
		char *Conversion;
		unsigned int MaxAxisPoints;
		float LowerLimit;
		float UpperLimit;
		char *Annotation;
		char *AxisPoints;
	} Axis_Descr;

/*************** START CHARACTERISTIC *****************/
		enum _Type {
		ASCII,
		CURVE,
		MAP,
		CUBOID,
		CUBE_4,
		CUBE_5,
		VAL_BLK,
		VALUE
	};

	typedef struct Characteristic {
		int nAxisDescr;
		char *sName;
		char *sId;
		enum _Type eType;
		unsigned long ulAddress;
		char *sDeposit;
		float fMaxDiff;
		char *sConversion;
		float fLowerLimit;
		float fUpperLimit;
		char *sAnnotation;
		char *sFormat;
		Axis_Descr *aAxisDescr[MAX_AXIS_DESCR];
	} Characteristic;

	Characteristic * CreateCharacteristic();
	void SetAxisDescr(Characteristic *characteristic, Axis_Descr *ActiveAxisDescr);
/************ END CHARACTERISTIC ************/

/************ START MEASUREMENT ************/

	typedef struct Measurement {
		char *sName;
		char *sId;
		char *sDataType; /* datatype should be enum eventually */
		char *sConversion;
		unsigned int uiResolution;
		float fAccuracy;
		float fLowerLimit;
		float fUpperLimit;
	} Measurement;

	Measurement * CreateMeasurement();
/************ START MEASUREMENT ************/

/************ START MODULE ************/
	typedef struct Module {
		/* Metadata */
		int nCharacteristics;
		int nMeasurements;
		int nAxisPts;
		/* Components */
		char *sName;
		char *sId;
		Axis_Pts *aAxisPts[MAX_AXIS_PTS];
		Characteristic *aCharacteristics[MAX_CHARACTERISTICS];
		Measurement *aMeasurements[MAX_MEASUREMENTS];
	} Module;

	void SetCharacteristic(Module *module, Characteristic *ActiveCharacteristic);
	void SetMeasurement(Module *module, Measurement *ActiveMeasurement);
	Module * CreateModule();
/************ END MODULE *************/

/************ START PROJECT **************/
	typedef struct Project {
		char sAsap2version[5]; /* Only one project per A2L file allowed, so this works */
		char *sName;
		char *sComment;
		/* Start Header */
		char *sHeaderComment;
		char *sVersion;
		char *sProjectNo;
		/* End Header */
		int nModules;
		Module *aModules[MAX_MODULES];
	} Project;

	static const Project reset_project; /* Null Project */

	void SetModule(Project *project, Module *ActiveModule);
	void FreeProject(Project *project);
/************ END PROJECT **************/