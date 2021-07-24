EESchema Schematic File Version 4
EELAYER 30 0
EELAYER END
$Descr A4 11693 8268
encoding utf-8
Sheet 1 1
Title "HDMI PMOD"
Date "2020-12-13"
Rev "A"
Comp ""
Comment1 ""
Comment2 ""
Comment3 ""
Comment4 ""
$EndDescr
$Comp
L Connector:HDMI_A_1.4 J0
U 1 1 5FD183EA
P 7800 3500
F 0 "J0" H 8230 3546 50  0000 L CNN
F 1 "HDMI_A_1.4" H 8230 3455 50  0001 L CNN
F 2 "ultra_librarian:10029449-111RLF" H 7825 3500 50  0001 C CNN
F 3 "https://en.wikipedia.org/wiki/HDMI" H 7825 3500 50  0001 C CNN
	1    7800 3500
	1    0    0    -1  
$EndComp
$Comp
L PMOD:PMOD-Device-x2-Type-XHS PMOD0
U 1 1 5FD1CEBB
P 3150 3250
F 0 "PMOD0" H 3075 3933 50  0000 C CNN
F 1 "PMOD-Device-x2-Type-XHS" V 2790 2540 50  0001 L CNN
F 2 "PMOD:pmod_pin_array_6x2_hs" V 2700 2540 60  0001 L CNN
F 3 "https://docs.google.com/a/mithis.com/spreadsheets/d/1D-GboyrP57VVpejQzEm0P1WEORo1LAIt92hk1bZGEoo/edit#gid=0" H 3075 3940 60  0001 C CNN
	1    3150 3250
	1    0    0    -1  
$EndComp
Text Label 6900 2900 0    50   ~ 0
TMDS_G+
Text Label 6900 3000 0    50   ~ 0
TMDS_G-
Text Label 6900 3100 0    50   ~ 0
TMDS_B+
Text Label 6900 3300 0    50   ~ 0
TMDS_CLK+
Text Label 6900 3400 0    50   ~ 0
TMDS_CLK-
Text Label 6900 2700 0    50   ~ 0
TMDS_R+
$Comp
L power:GND #PWR0101
U 1 1 5FD70667
P 3500 4000
F 0 "#PWR0101" H 3500 3750 50  0001 C CNN
F 1 "GND" H 3505 3827 50  0000 C CNN
F 2 "" H 3500 4000 50  0001 C CNN
F 3 "" H 3500 4000 50  0001 C CNN
	1    3500 4000
	1    0    0    -1  
$EndComp
$Comp
L Connector_Generic:Conn_02x04_Counter_Clockwise J1
U 1 1 5FD7C0CA
P 5050 4550
F 0 "J1" H 5100 4775 50  0000 C CNN
F 1 "Conn_02x04_Counter_Clockwise" H 5100 4776 50  0001 C CNN
F 2 "Connector_PinHeader_2.54mm:PinHeader_2x04_P2.54mm_Vertical" H 5050 4550 50  0001 C CNN
F 3 "~" H 5050 4550 50  0001 C CNN
	1    5050 4550
	1    0    0    -1  
$EndComp
$Comp
L power:+3.3V #PWR0102
U 1 1 5FD7FA30
P 3400 2500
F 0 "#PWR0102" H 3400 2350 50  0001 C CNN
F 1 "+3.3V" H 3415 2673 50  0000 C CNN
F 2 "" H 3400 2500 50  0001 C CNN
F 3 "" H 3400 2500 50  0001 C CNN
	1    3400 2500
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0103
U 1 1 5FD83393
P 7800 2400
F 0 "#PWR0103" H 7800 2250 50  0001 C CNN
F 1 "+5V" H 7815 2573 50  0000 C CNN
F 2 "" H 7800 2400 50  0001 C CNN
F 3 "" H 7800 2400 50  0001 C CNN
	1    7800 2400
	1    0    0    -1  
$EndComp
Text Label 7150 4200 0    50   ~ 0
HEAC-
Text Label 7150 4100 0    50   ~ 0
HEAC+
Wire Wire Line
	6950 4650 6950 3900
Wire Wire Line
	6950 3900 7400 3900
Wire Wire Line
	6850 4550 6850 3800
Wire Wire Line
	6850 3800 7400 3800
Wire Wire Line
	6750 4450 6750 3600
Wire Wire Line
	6750 3600 7400 3600
Wire Wire Line
	4500 5000 4500 4650
Wire Wire Line
	4500 4650 4850 4650
$Comp
L power:+3.3V #PWR0104
U 1 1 5FD98ACE
P 4500 4300
F 0 "#PWR0104" H 4500 4150 50  0001 C CNN
F 1 "+3.3V" H 4515 4473 50  0000 C CNN
F 2 "" H 4500 4300 50  0001 C CNN
F 3 "" H 4500 4300 50  0001 C CNN
	1    4500 4300
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0105
U 1 1 5FD9906C
P 4750 4300
F 0 "#PWR0105" H 4750 4150 50  0001 C CNN
F 1 "+5V" H 4765 4473 50  0000 C CNN
F 2 "" H 4750 4300 50  0001 C CNN
F 3 "" H 4750 4300 50  0001 C CNN
	1    4750 4300
	1    0    0    -1  
$EndComp
$Comp
L power:GND #PWR0106
U 1 1 5FD97254
P 4500 5000
F 0 "#PWR0106" H 4500 4750 50  0001 C CNN
F 1 "GND" H 4505 4827 50  0000 C CNN
F 2 "" H 4500 5000 50  0001 C CNN
F 3 "" H 4500 5000 50  0001 C CNN
	1    4500 5000
	1    0    0    -1  
$EndComp
Wire Wire Line
	4500 4550 4850 4550
Wire Wire Line
	4500 4300 4500 4550
Wire Wire Line
	4750 4450 4850 4450
Wire Wire Line
	4750 4300 4750 4450
Text Label 7200 3600 0    50   ~ 0
CEC
Text Label 7200 3800 0    50   ~ 0
SCL
Text Label 7200 3900 0    50   ~ 0
SDA
Text Notes 3950 2150 0    50   ~ 0
The differential characteristic impedance of each TMDS signal shall be 100 Ohms
Wire Wire Line
	7600 4600 7600 4700
Wire Wire Line
	7600 4700 7700 4700
Wire Wire Line
	8100 4700 8100 4600
Wire Wire Line
	7700 4600 7700 4700
Connection ~ 7700 4700
Wire Wire Line
	7700 4700 7800 4700
Wire Wire Line
	7800 4600 7800 4700
Connection ~ 7800 4700
Wire Wire Line
	7800 4700 7900 4700
Wire Wire Line
	7900 4600 7900 4700
Connection ~ 7900 4700
Wire Wire Line
	7900 4700 8000 4700
$Comp
L Device:R R1
U 1 1 5FDEF228
P 6050 4150
F 0 "R1" H 6120 4196 50  0000 L CNN
F 1 "2k" H 6120 4105 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 5980 4150 50  0001 C CNN
F 3 "~" H 6050 4150 50  0001 C CNN
	1    6050 4150
	1    0    0    -1  
$EndComp
$Comp
L Device:R R2
U 1 1 5FDEFF7C
P 6300 4150
F 0 "R2" H 6370 4196 50  0000 L CNN
F 1 "2k" H 6370 4105 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 6230 4150 50  0001 C CNN
F 3 "~" H 6300 4150 50  0001 C CNN
	1    6300 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 4300 6300 4650
$Comp
L power:+5V #PWR0107
U 1 1 5FDF32EE
P 6050 4000
F 0 "#PWR0107" H 6050 3850 50  0001 C CNN
F 1 "+5V" H 6065 4173 50  0000 C CNN
F 2 "" H 6050 4000 50  0001 C CNN
F 3 "" H 6050 4000 50  0001 C CNN
	1    6050 4000
	1    0    0    -1  
$EndComp
$Comp
L power:+5V #PWR0108
U 1 1 5FDF37F9
P 6300 4000
F 0 "#PWR0108" H 6300 3850 50  0001 C CNN
F 1 "+5V" H 6315 4173 50  0000 C CNN
F 2 "" H 6300 4000 50  0001 C CNN
F 3 "" H 6300 4000 50  0001 C CNN
	1    6300 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	8000 4600 8000 4700
Connection ~ 8000 4700
Wire Wire Line
	8000 4700 8100 4700
$Comp
L power:GND #PWR0109
U 1 1 5FE214F3
P 8100 4850
F 0 "#PWR0109" H 8100 4600 50  0001 C CNN
F 1 "GND" H 8105 4677 50  0000 C CNN
F 2 "" H 8100 4850 50  0001 C CNN
F 3 "" H 8100 4850 50  0001 C CNN
	1    8100 4850
	1    0    0    -1  
$EndComp
Wire Wire Line
	8100 4850 8100 4700
Connection ~ 8100 4700
Wire Wire Line
	3400 2500 3400 3200
Wire Wire Line
	3300 3900 3400 3900
Wire Wire Line
	3300 3200 3400 3200
Connection ~ 3400 3200
Wire Wire Line
	3400 3200 3400 3900
Wire Wire Line
	3500 4000 3500 3800
Wire Wire Line
	3300 3100 3500 3100
Wire Wire Line
	3300 3800 3500 3800
Connection ~ 3500 3800
Wire Wire Line
	3500 3800 3500 3100
Wire Wire Line
	5450 2800 7400 2800
Wire Wire Line
	5350 2700 5350 3400
Wire Wire Line
	5350 3400 3300 3400
Wire Wire Line
	5350 2700 7400 2700
Wire Wire Line
	3300 3500 5450 3500
Wire Wire Line
	5450 2800 5450 3500
Wire Wire Line
	3300 2900 4300 2900
Wire Wire Line
	3300 3000 4200 3000
Wire Wire Line
	7050 4100 7400 4100
Wire Wire Line
	7050 4100 7050 4750
Wire Wire Line
	7150 4200 7400 4200
$Comp
L Device:R R3
U 1 1 5FE91F95
P 5800 4150
F 0 "R3" H 5870 4196 50  0000 L CNN
F 1 "2k" H 5870 4105 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 5730 4150 50  0001 C CNN
F 3 "~" H 5800 4150 50  0001 C CNN
	1    5800 4150
	1    0    0    -1  
$EndComp
Wire Wire Line
	6050 4300 6050 4550
Wire Wire Line
	6050 4550 6850 4550
$Comp
L power:+3.3V #PWR0110
U 1 1 5FE97F7B
P 5800 4000
F 0 "#PWR0110" H 5800 3850 50  0001 C CNN
F 1 "+3.3V" H 5815 4173 50  0000 C CNN
F 2 "" H 5800 4000 50  0001 C CNN
F 3 "" H 5800 4000 50  0001 C CNN
	1    5800 4000
	1    0    0    -1  
$EndComp
Wire Wire Line
	5800 4300 5800 4450
Wire Wire Line
	5800 4450 6750 4450
Wire Wire Line
	5250 2700 5250 2900
Wire Wire Line
	5250 2900 7400 2900
Wire Wire Line
	3300 2700 5250 2700
Wire Wire Line
	5150 2800 5150 3000
Wire Wire Line
	5150 3000 7400 3000
Wire Wire Line
	3300 2800 5150 2800
Wire Wire Line
	5550 3400 5550 3300
Wire Wire Line
	5550 3300 4200 3300
Wire Wire Line
	4200 3300 4200 3000
Wire Wire Line
	5550 3400 7400 3400
Wire Wire Line
	4300 2900 4300 3200
Wire Wire Line
	4300 3200 5650 3200
Wire Wire Line
	5650 3200 5650 3300
Wire Wire Line
	5650 3300 7400 3300
Wire Wire Line
	5750 3600 5750 3100
Wire Wire Line
	3300 3600 5750 3600
Wire Wire Line
	5750 3100 7400 3100
Wire Wire Line
	5850 3700 5850 3200
Wire Wire Line
	3300 3700 5850 3700
Wire Wire Line
	5850 3200 7400 3200
Wire Wire Line
	4850 4750 4750 4750
Wire Wire Line
	4750 4750 4750 4900
Wire Wire Line
	4750 4900 5800 4900
Wire Wire Line
	5800 4900 5800 4450
Connection ~ 5800 4450
Wire Wire Line
	5350 4750 7050 4750
Wire Wire Line
	6050 4550 5550 4550
Wire Wire Line
	5550 4550 5550 4650
Wire Wire Line
	5550 4650 5350 4650
Connection ~ 6050 4550
Wire Wire Line
	6300 4650 6950 4650
Wire Wire Line
	6300 4650 5650 4650
Wire Wire Line
	5650 4650 5650 4450
Wire Wire Line
	5650 4450 5350 4450
Connection ~ 6300 4650
$Comp
L power:GND #PWR0111
U 1 1 5FEA668D
P 6300 5550
F 0 "#PWR0111" H 6300 5300 50  0001 C CNN
F 1 "GND" H 6305 5377 50  0000 C CNN
F 2 "" H 6300 5550 50  0001 C CNN
F 3 "" H 6300 5550 50  0001 C CNN
	1    6300 5550
	1    0    0    -1  
$EndComp
Wire Wire Line
	6300 5100 7150 5100
Wire Wire Line
	6300 5250 6300 5100
$Comp
L Device:R R4
U 1 1 5FEA386B
P 6300 5400
F 0 "R4" H 6370 5446 50  0000 L CNN
F 1 "100k" H 6370 5355 50  0000 L CNN
F 2 "Resistor_SMD:R_0805_2012Metric" V 6230 5400 50  0001 C CNN
F 3 "~" H 6300 5400 50  0001 C CNN
	1    6300 5400
	1    0    0    -1  
$EndComp
Wire Wire Line
	5350 4550 5450 4550
Wire Wire Line
	5450 4550 5450 5100
Wire Wire Line
	5450 5100 6300 5100
Connection ~ 6300 5100
Wire Wire Line
	7150 4200 7150 5100
Text Label 6900 3200 0    50   ~ 0
TMDS_B-
Text Label 6900 2800 0    50   ~ 0
TMDS_R-
$EndSCHEMATC
