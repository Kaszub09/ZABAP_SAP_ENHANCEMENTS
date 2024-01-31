# ZABAP_SAP_ENHANCEMENTS
Report to show enhancements in SAP programs available for user

![obraz](https://github.com/Kaszub09/ZABAP_SAP_ENHANCEMENTS/assets/34368953/fd3ca469-4272-4547-8520-4b26c5aac87d)
![obraz](https://github.com/Kaszub09/ZABAP_SAP_ENHANCEMENTS/assets/34368953/7ffd6504-3630-4262-aeed-94818412b071)
![obraz](https://github.com/Kaszub09/ZABAP_SAP_ENHANCEMENTS/assets/34368953/9dd9987a-1910-46c7-bb97-294c96770395)

## Features
Report is based on https://community.sap.com/t5/enterprise-resource-planning-blogs-by-members/program-to-display-exits-and-badi/ba-p/12955380 - original version lacks some features, which I needed and decided to add - and at the same time rewrite report to use CL_SALV_TABLE for easier display/formatting/filtering instead of original WRITE statement.

- Shows User-Exits, BADIs, Enhancement Spots, Composite Enhancements Spots
- Shows all implementation for given enhancement - as well as information, whether it's active and if it's SAP BADI for internal use only
- You can double click both enhancement name or implementation name to display given object
- 3 colors: green or active implementation, blue for inactive, and orange for internal SAP enhancements

## Installation
Through abapGit https://github.com/abapGit/abapGit. Install this project after installing https://github.com/Kaszub09/ZABAP_SALV_REPORT.

## Requirements
Requires class from another project: https://github.com/Kaszub09/ZABAP_SALV_REPORT.

Written in ABAP 750.
