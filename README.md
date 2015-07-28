# AVIC-NEX
A guide and discussion place for modding the AVIC NEX


**The contributors to this repository take no liabilty to any damage you may cause to your AVIC NEX by performing methods described here.**


#Testmodes
Test modes allow you to access many of the internal functions to perform various testing operations and some copying and writing functions.

##Structure 
The strings for the Testmode contain 3 fields and some optional fileds in the structure:

1. 3 digit character count of 1st field
2. 1st field sting
3. 3 digit character count of 2nd field
4. 2nd field which is the model name or ALL:
	* ALL
	* KM500
	* NX263
	* NX263A
	* NX264A
	* NX264
	* NX264D
5. 3 digit character count of 3rd field
6. 3rd field	
7. Unknown string of: 0082013010100820201230000

##Generation
To generate a Testmode file use the following:

```
perl TestKeys/encode.pl SOME_STRING_DEFINED_BELOW OUTPUTFILE.KEY
```

##Booting

To boot a Testmode, place a file with the encrypted contents and a name of TESTMODE_A.KEY in the root directory of a USB stick, changing the last letter to match the headers defined below.

## Check Order

TestModes are checked in the following order:

1. TESTMODE_A
2. TESTMODE_N
3. TESTMODE_S

## Testmodes
The following are all the known testmodes.

###TESTMODE_A
Testmode A launches after the deck has fully booted into the Testmode.apk on the device. The settings differ based on the encrypted contents within the TESTMODE_A files.

The following modes are currently known to exist, (but not all of them have booted):

Mode Name 				|  Booted		 |Contents To Encrypt
---------------------- |-----------------| -------------
SERVICE 				| Yes  			  |007SERVICE003ALL00833333333007SERVICE0082013010100820201230000
XXTECHNICALXX 			| Yes  			  |013XXTECHNICALXX003ALL00833333333013XXTECHNICALXX0082013010100820201230000
PRODUCT 				| Yes  			  |007PRODUCT003ALL00833333333007PRODUCT0082013010100820201230000
NORMAL 					| No 			  |006NORMAL003ALL00833333333006NORMAL0082013010100820201230000
DIRECT					| No  			  |006DIRECT003ALL00833333333006DIRECT0082013010100820201230000
AUTO 					| No  			  |004AUTO003ALL00833333333004AUTO0082013010100820201230000


Known functions in each mode:

1. Direct Mode
	* ProgramFunction
	* ModeChngFunction
	* InitFactoryDefFunction
	* BluetoothFunction
	* VersionInfoFunction
	* ProdInfoFunction
	* GraphicsFunction
	* UsbFunction
2. Normal Mode
	* VersionInfoFunction
	* ProgramFunction
	* LogFunction
	* FileMaintenanceFunction
	* DriveMaintenceFun
	* InitFactoryDefFunction
	* InitUserArea
	* GyroSensorFunction
	* SelfCheckFunction
	* TouchPanelFunction
	* WirRemoteCtrFunction
	* LearningWiredCtrlFunction
	* PioFunction
	* AsyncSerilPrtFunction
	* RGBIllumiFunction
	* MonitorFunction
	* GraphicsFunction
	* GpsInfoFunction
	* GpsPositionFunction
	* SensorFunction
	* GPSModuleFunction
	* TimeFunction
	* ExtConnInfoFunction
	* TmprtrSnsrFunction
	* FanContFunction
	* FlshRomFunction
	* SdFunction
	* StrgeSdFunction
	* BluetoothFunction
	* BtLineTest
	* TelFunction
	* EchoLSIFunction
	* AVTestFunction
	* IPODTest
	* IpodCertificationFunction
	* AppModeMixFunction
	* SXIFunction
	* HDRadioFunction
	* RdsTmcFunction
	* AudioFunction
	* ProdAudioFunction
	* VideoFunction
	* AutoEQFunction
	* UsbFunction
	* UsbComFunction
	* SystemFunction
	* FlapFunction
	* BackCameraFunction
	* ModeChngFunction
	* ProdInfoFunction
	* WrProInfFunction
	* CCIDWriteFunction
	* TestResult
	* ChngFlgDbgSrilFunction
	* DCDCConverterSynchronization
	* RGBIllumiPWMRegulation
	* RGBIllumiFunction
	* MmoryChckFunction
	* CopyDeviceFun


###TESTMODE_N
Testmode N boots from the NORFlash or Recovery. The modes differ based on the encrypted contents within the TESTMODE_N files.


The following boot types and command combinations are known to exist:

Boot Type 	|	Command		 |  Tested      | Booted |Contents To Encrypt
------------|----------------|-------------|----------------| -------------
Recovery 	|	AllUpdate    | Yes  		|	Yes          | 008Recovery003ALL00833333333009AllUpdate0082013010100820201230000
NORFLASH 	|	COPYDEVICE   | No	  		|	Yes          | 008NORFLASH003ALL00833333333010COPYDEVICE0082013010100820201230000
NORFLASH 	|	MODECHANGE   | Yes  		|	Yes          | 008NORFLASH003ALL00833333333010MODECHANGE0082013010100820201230000


The following boot types are known to exist:

Boot Type 	| Tested | Booted |	What it does
----------------|-----|--------------|---------------------
Recovery 	| Yes	 | Yes			 |Boots the recovery partion on the Internal SD Card    
NORFLASH 	| Yes	 | Yes			 |Boots the EasyRecovery Partition stored on the NorFlash (UBoot) 


The following commands are known to exist:

Command 	| Tested	| Booted   |What it does
------------|----------|-----------------|-----------------------
AllUpdate 	| Yes		| Yes 			  | Enables you to force an update like a regular NEX Update 
COPYDEVICE 	| Yes		| No			  | Copies an external device directly to the Internal Sd Card **(Unsure)**
MODECHANGE 	| Yes		| Yes			  | Changes a mode of somesort  **(Unsure)**


###TESTMODE_S
We are unsure what this does except that it reads 1 byte, subtracts 0x31 and then saves that value into the BSP SubMode.

##Known TESTMODE BSP Information
The following is a data dump of what the TestMode files do with the BSP.

### BSP Side Information
```
   Magic Number     :0x%08lx(a55a5aa5:Valid, other:Invalid)
0: Boot Mode        :0x%08lx(0:Normal, 1:Recovery, 2:EasyRecovery, 3:Re-EasyRecovery, default:Normal)
1: Launch Mode      :0x%08lx(0:APL, 1:TestMode.apk, 2:Slave TestMode, 3:Boot Error, default:APL)
2: TestMode Sub-Mode:0x%08lx(0:TextMode_A.key,1:Serv Mode,2:Tech Mode,default:TechMode)
3? Bootimage Side   :0x%08lx(0:Side A,        1:Side B,               default:Side A)
4? Recoveryimg Side :0x%08lx(0:Side A,        1:Side B,               default:Side A)
5? Debug Switch     :0x%08lx(0:OFF,           1:ON,                   default:OFF)
6? Usb OTG Switch   :0x%08lx(0:Host,          1:Device,               default:Host)
7? Memchk flag      :0x%08lx(0:No,            1:Yes,                  default:No)
8: Warp boot        :0x%08lx(0:Side A,        1:Side B,               default:Side A)
8? Boot Sub-Mode    :0x%08lx(0:Normal,        1:Catch snapshot,2:Warp,default:Normal)
A: Update flag      :0x%08lx(0:Recovery-Update, 1:uboot update, 2:boot.img update,
                          3:recovery.img update, 4:system.img update,
                          5:opening data update, 6:UI update, 7:All image update,
                          8:TESTMODE_N.KEY, 9:easyrecovery copy,
                          a:easyrecovery copy&verify, b:password key copy&verify,
                          c:easyrecovery mode change,
                    default:Recovery-Update)
B: Update sub-flag    :0x%08lx(0:SD Card,        1:USB1,      2:USB2   default:SD Card)
UI Update  flag    :0x%08lx(0:non-updating,   1:updating,    default:non-updating)
Reserved1  flag    :0x%08lx(default:0xFFFFFFFF)
Reserved2  flag    :0x%08lx(default:0xFFFFFFFF)
```
###TESTMODE_A

```
write
1, 1
2, 0
LMode (1, 1, 4 = sizeof) = TestMode.apk
SubMode (2, 0, 4 = sizeof) = TextMode_A.key
```

###TESTMODE_N

###RecoveryAllUpdate

```
BMode (0, 1, 4 = sizeof) = BootMode = recovery
SetUpdateFlag (10, 0, 4) = Update flag = 0:Recovery-Update
SetSubUpdateFlag (11, 2, 4) = 0:SD Card
```
###NORFLASH CopyDevice

```
BMode (0, 2, 4) = Boot Mode = EasyRecovery
SetUpdateFlag (10, 8, 4) = Update flag = a:easyrecovery copy&verify
SetSubUpdateFlag (11, x, 4) x = device where testfile found
```

###NORFLASH ChangeMode

```
BMode (0, 2, 4) = Boot Mode = EasyRecovery
SetUpdateFlag (10, 12, 4) = Update flag = c:easyrecovery mode change
```

###TESTMODE_S
```
LMode = 2 (slave testmode)
LMode (1, 2, 4 = sizeof)
SubMode (2, [3,4,5,6 by table], 4 = sizeof)
```

#Update File Modification
The following describes how to modify the update files for your own use. 

**It is currently unkonwn if the AVIC NEX truely boots the modifications**

**Any modifications made to the BOOT.img kernel/prg cause the deck to not boot. There is a checksum that we have not yet figured out on the Boot partiton.**


##Usage
To open up a AVIC NEX Update zip for modificiation perform the following on a Ubuntu Based System:

**AVIC x100 Based:**

```
./Firmwares/AVIC.sh firmware.zip 5100 150
```

**AVIC x000 Based:**

```
./Firmwares/AVIC.sh firmware.zip 5000 140
```


#Cross Update x000 to a x100
The following is how to cross update your x000 AVIC to a x100.

1. Download the x100 update relating to your model.
2. Rename all the 150's to 140
3. Change the root folder from 5100 to 5000
4. Flash the update

The deck will now belive it is a x100. From now on you will need to use x100 update files without having to do the rename.

If you wish to go back to the x000 do the reverse of the above.

**All bluetooth audio is known not to work with this method currently**
