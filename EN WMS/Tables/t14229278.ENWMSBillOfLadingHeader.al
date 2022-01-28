//#region Copy Right Information
// Copyright Elation LLC  Corp. 2016-2021.
// By opening this object you acknowledge that this object includes confidential information and intellectual
// property of ELation LLC. and that this work is protected by U.S. and international copyright laws and agreements.
//#endregion Copy Right Information

/// <summary>
/// Table EN WMS Bill of Lading Header (ID 14229225).
/// </summary>
table 14229278 "WMS Bill of Lading Header ELA"
{
    fields
    {
        field(10; "No."; Code[20])
        {
        }
        field(20; Status; Option)
        {
            OptionCaption = 'Open,In Process,Registered,Cancel';
            OptionMembers = Open,"In Process",Registered,Cancel;

            trigger OnValidate()
            var
                DoRegister: Boolean;
                Customer: Record "Customer";
            begin
                IF "Source Document" = "Source Document"::"Outbound Transfer" THEN
                    EXIT;

                IF Status = Status::Registered THEN BEGIN
                    IF NOT (
                       "Product Temp. Checked" AND
                       "Temp Tag No. Checked" AND
                       "Customer PO No. Checked" AND
                       "Pallet Count Checked" AND
                       "Case Count Checked")
                    THEN
                        ERROR(TEXT50011);

                    DoRegister := FALSE;
                    IF ShipDashMgt.CheckBOLQtyAgainstPickedQty("Sales Order No.") OR
                       NOT ShipDashMgt.IsOrderFullyPicked("Sales Order No.") THEN BEGIN
                        IF CONFIRM(STRSUBSTNO(TEXT50014, "Sales Order No.", TRUE)) THEN
                            DoRegister := TRUE
                        ELSE
                            ERROR('');
                    END ELSE
                        DoRegister := TRUE;

                    IF DoRegister THEN BEGIN
                        IF "Loading Date" < TODAY THEN
                            IF CONFIRM(STRSUBSTNO(TEXT50013, "Loading Date", TRUE)) THEN
                                "Loading Date" := TODAY;
                        Customer.GET("Customer No.");
                        // IF NOT Customer."Allow multiple shipments/order" THEN //tbr
                        IF NOT ShipDashMgt.IsOrderFullyPicked("Sales Order No.") THEN
                            ERROR(TEXT50010);

                        ShipDashMgt.UpdateDatesOnRelDocs("Sales Order No.", "Loading Date", 0D);
                        // IF CONFIRM(STRSUBSTNO(TEXT50008, "Sales Order No.")) THEN BEGIN
                        //     // WMSServices.PrintBillOfLading("No.");
                        //     // WMSServices.PrintDeliveryNote("Sales Order No.");
                        // END ELSE
                        //     // WMSServices.AddBOLOnSalesOrder("No.");

                        //>>EN1.07
                        IF "Registered By User" = '' THEN BEGIN
                            "Registered By User" := USERID;
                            "Registeration Date Time" := CURRENTDATETIME;
                        END ELSE BEGIN
                            "Re-Registered By User" := USERID;
                            "Re-Registeration Date Time" := CURRENTDATETIME;
                        END;
                        //>>EN1.08
                        //<<EN1.15
                        // DeliveryLoadHdr.RESET;
                        // DeliveryLoadHdr.SETRANGE("Load ID", "Load ID");
                        // IF DeliveryLoadHdr.FINDFIRST THEN BEGIN
                        //     DeliveryLoadHdr.VALIDATE(Closed, TRUE);
                        //     DeliveryLoadHdr.MODIFY;
                        // END;
                        //>>EN1.15
                        MESSAGE(TEXT50009);
                    END;
                END ELSE BEGIN
                    "Re-Opened By User" := USERID;
                    "Re-Opened By Date Time" := CURRENTDATETIME;
                END;
                //>>EN1.04
                //EN1.19 Trigger ASN Generation
                // IF (Status = Status::Registered) AND "EDI Order" AND
                //     ("EDI Trade Partner No." <> '') THEN
                //     IF EDITradePartner.GET("EDI Trade Partner No.") THEN
                //         IF EDITradePartner."ASN Enabled" THEN
                //             SendASN;
            end;
        }
        field(29; "Source Document"; Option)
        {
            Caption = 'Source Document';
            Description = 'EN1.13';
            Editable = true;
            OptionCaption = 'Sales Order,Outbound Transfer';
            OptionMembers = "Sales Order","Outbound Transfer";
        }
        field(30; "Sales Order No."; Code[20])
        {
            TableRelation = IF ("Source Document" = CONST("Sales Order")) "Sales Header"."No." WHERE("Document Type" = CONST(Order),
                                                                                              Status = CONST(Released))
            ELSE
            IF ("Source Document" = CONST("Outbound Transfer")) "Transfer Header"."No." WHERE(Status = CONST(Released));

            trigger OnValidate()
            begin
                PopulateHeader;
            end;
        }
        field(40; "Shipment Doc. No."; Code[20])
        {
            TableRelation = "Warehouse Shipment Header" WHERE("No." = FIELD("Shipment Doc. No."));
        }
        field(50; "IC Partner Code"; Code[20])
        {
        }
        field(60; "Company Code"; Code[20])
        {
        }
        field(100; "External Document No."; Code[20])
        {
        }
        field(110; "IC Document No."; Code[20])
        {
        }
        field(120; "Ship-to Code"; Code[50])
        {
        }
        field(121; "Ship-to"; Text[50])
        {
        }
        field(130; "Loading Date"; Date)
        {

            trigger OnValidate()
            var
                WhseShipHdr: Record "Warehouse Shipment Header";
            // DLHdr: Record "50095";
            begin
                //<<EN1.16
                IF Status <> Status::Registered THEN BEGIN
                    ShipDashMgt.UpdateDatesOnRelDocs("Sales Order No.", "Loading Date", 0D);
                    // DLHdr.RESET;
                    // DLHdr.SETRANGE(DLHdr."Load ID", "Load ID");
                    // IF DLHdr.FINDFIRST THEN BEGIN
                    //     DLHdr."Load Date" := "Loading Date";
                    //     DLHdr.MODIFY;
                    // END;
                END ELSE
                    ERROR(TEXT50015);
                //>>EN1.16
            end;
        }
        field(140; "Consignee Name"; Text[50])
        {
        }
        field(150; "Consignee Street"; Text[250])
        {
        }
        field(160; "Consignee City and State"; Text[200])
        {
        }
        field(170; "Consignee Zip"; Code[20])
        {
        }
        field(171; "Consignee Telelphone No."; Text[30])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(180; "Customer PO No."; Code[20])
        {
        }
        field(190; "Shipment Method Code"; Code[10])
        {
            Caption = 'Shipment Method Code';
            Description = 'EN1.02';
            TableRelation = "Shipment Method";

            trigger OnValidate()
            var
                lCust: Record "Customer";
            begin
            end;
        }
        field(210; "User ID"; Code[20])
        {
        }
        field(220; Loader; Code[10])
        {
        }
        field(225; Checker; Code[10])
        {
        }
        field(230; "Seal No."; Code[10])
        {
        }
        field(240; "Product Temp."; Decimal)
        {
        }
        field(250; "Truck Temp."; Decimal)
        {
        }
        field(260; "Shipper Name"; Text[50])
        {
        }
        field(261; "Shipper Person"; Code[20])
        {
        }
        field(262; "Carrier Name"; Code[20])
        {
        }
        field(263; "Carrier Person"; Code[20])
        {
        }
        field(264; Closed; Boolean)
        {
            Enabled = false;
        }
        field(310; "Shipper Street"; Text[100])
        {
        }
        field(320; "Shipper City and State"; Text[200])
        {
        }
        field(330; "Shipper Zip"; Text[30])
        {
        }
        field(350; "Shipper Telephone"; Text[30])
        {
            ExtendedDatatype = PhoneNo;
        }
        field(360; "Total Weight"; Decimal)
        {
            CalcFormula = Sum("WMS Bill of Lading Detail ELA".Weight where("Bill of Lading No." = field("No.")));
            FieldClass = FlowField;
        }

        field(370; "Total Cases"; Decimal)
        {
            // CalcFormula = Sum("Bill of Lading Detail"."Qty on Pallet" WHERE(Bill of Lading No.=FIELD(No.),
            //                                                                  Line Status=FILTER(<>Deleted),
            //                                                                  Pallet No.=FILTER(<>0)));
            FieldClass = FlowField;
        }
        field(380; "Temp Tag No."; Code[10])
        {
        }
        field(390; "Door No."; Code[10])
        {
        }
        field(400; "Trailer No."; Code[10])
        {
        }
        field(410; "Member PO No."; Code[20])
        {
        }
        field(420; "Customer No."; Code[20])
        {
            Description = 'EN1.11';
        }
        field(430; "Customer Name"; Text[50])
        {
            Description = 'EN1.11';
        }
        field(500; Loaded; Boolean)
        {
            Editable = false;
            FieldClass = Normal;
        }
        field(1000; Signature; BLOB)
        {
            Description = 'EN1.01';
            SubType = Bitmap;
        }
        field(1010; "Manual BOL"; Boolean)
        {
        }
        field(2000; "Product Temp. Checked"; Boolean)
        {
            Description = 'EN1.08';
        }
        field(2010; "Truck Temp. Checked"; Boolean)
        {
            Description = 'EN1.08';
        }
        field(2020; "Temp Tag No. Checked"; Boolean)
        {
            Description = 'EN1.08';
        }
        field(2030; "Customer PO No. Checked"; Boolean)
        {
            Description = 'EN1.08';
        }
        field(2040; "Pallet Count Checked"; Boolean)
        {
            Description = 'EN1.08';
        }
        field(2050; "Case Count Checked"; Boolean)
        {
            Description = 'EN1.08';
        }
        field(3010; "Registered By User"; Code[20])
        {
            Description = 'EN1.08';
        }
        field(3020; "Registeration Date Time"; DateTime)
        {
            Description = 'EN1.08';
        }
        field(3030; "Re-Opened By User"; Code[20])
        {
            Description = 'EN1.08';
        }
        field(3040; "Re-Opened By Date Time"; DateTime)
        {
            Description = 'EN1.08';
        }
        field(3050; "Re-Registered By User"; Code[20])
        {
            Description = 'EN1.08';
        }
        field(3060; "Re-Registeration Date Time"; DateTime)
        {
            Description = 'EN1.08';
        }
        field(3070; "Locked By User ID"; Code[20])
        {
            Description = 'EN1.09';
        }
        field(3080; "Locked Date Time"; DateTime)
        {
            Description = 'EN1.09';
        }
        field(3090; "Un-locked By User ID"; Code[20])
        {
            Description = 'En1.09';
        }
        field(3100; "Un-locked Date Time"; DateTime)
        {
            Description = 'EN1.09';
        }
        field(3110; "Re-Locked By User ID"; Code[20])
        {
            Description = 'EN1.09';
        }
        field(3120; "Re-Locked Date Time"; DateTime)
        {
            Description = 'EN1.09';
        }
        field(3130; Locked; Boolean)
        {
            Description = 'EN1.09';
            Editable = true;

            trigger OnValidate()
            begin
                //<<EN1.09
                IF Locked THEN BEGIN
                    IF "Locked By User ID" = '' THEN BEGIN
                        "Locked By User ID" := USERID;
                        "Locked Date Time" := CURRENTDATETIME;
                        Locked := TRUE;
                    END ELSE
                        IF "Locked By User ID" <> '' THEN BEGIN
                            "Re-Locked By User ID" := USERID;
                            "Re-Locked Date Time" := CURRENTDATETIME;
                            Locked := TRUE;
                        END;
                END ELSE BEGIN
                    "Un-locked By User ID" := USERID;
                    "Un-locked Date Time" := CURRENTDATETIME;
                    Locked := FALSE;
                END;
                //>>EN1.09
            end;
        }
        field(50001; "Load ID"; Code[20])
        {
            Description = 'EN1.14';
        }
        field(50018; "EDI Order"; Boolean)
        {
            Description = 'EN2.0';
        }
        field(50019; "EDI Trade Partner No."; Code[20])
        {
            Description = 'EN2.0';
            // TableRelation = "E.D.I. Trade Partner".No.;
        }
        field(50020; "EDI ASN Sent"; Boolean)
        {
            Description = 'CF0097';
        }
        field(50021; "EDI ASN Sent Date Time"; DateTime)
        {
            Description = 'CF0097';
        }
        field(50056; "EDI ASN Generated"; Boolean)
        {
            Caption = 'EDI ASN Generated';
            Description = 'EN2.0';
            Editable = false;

            trigger OnValidate()
            begin
                /*///
                IF "EDI ASN Generated" AND NOT Posted THEN BEGIN
                  PackingRule.GetPackingRule("Ship-to Type","Ship-to No.","Ship-to Code");
                  IF PackingRule."Auto Post when ASN Send" THEN
                    BillOfLadingMgt.PostBillOfLading(Rec);
                END;
                */

            end;
        }
        field(50057; "EDI ASN Gen. Date"; Date)
        {
            Caption = 'EDI ASN Gen. Date';
            Description = 'EN2.0';
            Editable = false;
        }
        field(50058; "EDI ASN"; Boolean)
        {
            Caption = 'EDI ASN';
            Description = 'EN2.0';
        }
        field(50059; "EDI Internal Doc. No."; Code[10])
        {
            Caption = 'EDI Internal Doc. No.';
            Description = 'EN2.0';
            Editable = false;
        }
        field(50060; "ASN-MAN Per SSCC-18"; Code[48])
        {
            Description = 'EN2.0';
        }
    }

    keys
    {
        key(Key1; "No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    trigger OnDelete()
    begin
        IF Status <> Status::Open THEN BEGIN
            BOLLine.RESET;
            // BOLLine.SETRANGE( "Bill of Lading No.", "No."); //tbr
            // BOLLine.DELETEALL;
        END;
    end;

    trigger OnInsert()
    begin
        IF "No." = '' THEN
            "No." := GetNextBOLNo();

        IF "Shipper Person" = '' THEN
            "Shipper Person" := USERID;
    end;

    var
        Company: Record "Company";
        WMSSetup: Record "WMS Setup ELA";
        // ICPartner: Record "413";
        BOLLine: Record "WMS Bill of Lading Detail ELA";
        TmpSalesLine: Record "Sales Line" temporary;
        SalesLine: Record "Sales Line";
        NoSeriesMgt: Codeunit NoSeriesManagement;
        TEXT50000: Label 'Bill of Lading %1 exists for Order No. %2 Company %3';
        TEXT50001: Label 'Sales Order %1 not found in %2 Company';
        TEXT50002: Label 'Bin %1 rank %2';
        TEXT50003: Label 'Quantity is less than Full Pallet';
        TEXT50004: Label 'Full Pallet per Item UOM';
        TEXT50005: Label 'Pallet UOM not found';
        TEXT50006: Label 'Bill of lading is already registered.';
        // SalesDashbrdMgt: Codeunit "50002";
        TEXT50007: Label 'The mandatory fields are empty. ';
        ShipDashMgt: Codeunit "Shipment Mgmt. ELA";
        WMSServices: Codeunit "WMS Activity Mgmt. ELA";
        TEXT50008: Label 'Do you want to print Bill of lading and Delivery note for Order %1?';
        TEXT50009: Label 'Bill of lading has been registered.';
        TEXT50010: Label 'Bill of lading cannot be registered. Not all lines have been picked. Review the order';
        TEXT50011: Label 'Bill of lading is not verified. Please verify checks first';
        TEXT50012: Label 'Qty. on bill of lading is not matching with total picked qty. ';
        TEXT50013: Label 'Loading date %1 is less than today? Do you want to update loading date as of today on bill of lading?';
        TEXT50014: Label 'Order %1 has quantities that are not on this bol. Do you still want to register this BOL?';
        TEXT50015: Label 'Bill of lading is already registered.Re open bill of lading to make changes.';
        TEXT50016: Label 'Bill of lading %1 is already registered.Reopen BOL to make changes';
        SalesDashbrdMgt: Codeunit "Shipment Mgmt. ELA";
    // EDITradePartner: Record "14002360";

    procedure GetNextBOLNo(): Code[20]
    begin
        WMSSetup.GET;
        WMSSetup.TESTFIELD(WMSSetup."Bill Of Lading Nos.");
        EXIT(NoSeriesMgt.GetNextNo(WMSSetup."Bill Of Lading Nos.", 0D, TRUE));
    end;

    procedure PopulateHeader()
    var
        lSalesHeader: Record "Sales Header";
        lSalesLine: Record "Sales Line";
        lTransferHdr: Record "Transfer Header";
        lTransferLine: Record "Transfer Line";
        CompanyInfo: Record "Company Information";
        Location: Record "Location";
        lCustomer: Record "Customer";
        // ICPartner: Record "413";
        ICCompInfo: Record "Company information";
        ShipToName: Text[50];
        CurrCount: Integer;
        CurrParentID: Integer;
        CompanyCode: Code[10];
        lItemUOM: Record "Item Unit of Measure";
        PalletNo: Integer;
        RemQty: Decimal;
        QtyPerUOM: Decimal;
        BinContent: Record "Bin Content";
        NextLineNo: Integer;
        SrcCompany: Code[50];
        ShipToCode: Code[50];
        DoFillLocInfo: Boolean;
    begin
        //<<EN1.13
        IF "Source Document" = "Source Document"::"Outbound Transfer" THEN BEGIN
            IF lTransferHdr.GET("Sales Order No.") THEN BEGIN
                "Ship-to Code" := lTransferHdr."Transfer-to Code";
                SrcCompany := COMPANYNAME;
                "Consignee Name" := lTransferHdr."Transfer-to Name";
                "Consignee Street" := lTransferHdr."Transfer-to Address";
                "Consignee City and State" := lTransferHdr."Transfer-to City" + ', ' + lTransferHdr."Transfer-to County"; //EN1.06
                "Consignee Zip" := lTransferHdr."Transfer-to Post Code";
                "Consignee Telelphone No." := '';
                "External Document No." := lTransferHdr."External Document No.";
                "Customer PO No." := lTransferHdr."External Document No.";
                "User ID" := USERID;
                "Shipment Method Code" := lTransferHdr."Shipment Method Code";
                "Customer No." := lTransferHdr."Transfer-to Code";
                "Customer Name" := lTransferHdr."Transfer-to Name";
            END;
        END ELSE
            IF lSalesHeader.GET(lSalesHeader."Document Type"::Order, "Sales Order No.") THEN BEGIN
                // SalesDashbrdMgt.GetShipToInfo("Sales Order No.", ShipToCode, ShipToName);
                "Ship-to Code" := ShipToCode;

                // //<<EN1.19 ASN
                // IF lSalesHeader."EDI Order" THEN BEGIN
                //     "EDI Order" := lSalesHeader."EDI Order";
                //     "EDI Trade Partner No." := lSalesHeader."EDI Trade Partner";
                //     "EDI Internal Doc. No." := lSalesHeader."EDI Internal Doc. No.";
                // END;
                //>>EN1.19

                // IF lSalesHeader."IC Source Partner" <> '' THEN BEGIN
                //     "IC Partner Code" := lSalesHeader."IC Source Partner";
                //     Company.RESET;
                //     Company.SETRANGE(Company."Company Code", lSalesHeader."IC Source Partner");
                //     IF Company.FINDFIRST THEN
                //         SrcCompany := Company.Name;
                // END ELSE
                //     SrcCompany := COMPANYNAME;

                // IF Company.GET(SrcCompany) THEN
                //     "Company Code" := Company."Company Code";

                "Consignee Name" := lSalesHeader."Ship-to Name";
                "Consignee Street" := lSalesHeader."Ship-to Address";
                "Consignee City and State" := lSalesHeader."Ship-to City" + ', ' + lSalesHeader."Ship-to County"; //EN1.06
                "Consignee Zip" := lSalesHeader."Ship-to Post Code";
                "Consignee Telelphone No." := '';
                // "IC Document No." := lSalesHeader."IC Source Order No.";
                // IF lSalesHeader."IC External Doc. No." <> '' THEN BEGIN
                //     "External Document No." := lSalesHeader."IC External Doc. No.";
                //     "Customer PO No." := lSalesHeader."IC External Doc. No.";
                // END ELSE BEGIN
                "External Document No." := lSalesHeader."External Document No.";
                "Customer PO No." := lSalesHeader."External Document No.";
                // END;

                "User ID" := USERID;
                "Shipment Method Code" := lSalesHeader."Shipment Method Code";
                ///UPG  "Member PO No." := lSalesHeader."Customer Order No.";
                "Customer No." := lSalesHeader."Sell-to Customer No."; //EN1.11
                "Customer Name" := lSalesHeader."Sell-to Customer Name"; //EN1.11
                                                                         //>>EN1.03
            END;


        //<<<E1.20
        DoFillLocInfo := TRUE;
        // lCustomer.GET(lSalesHeader."Sell-to Customer No.");
        // IF lCustomer."Show IC Comp. info As Shipper" THEN BEGIN
        //     lCustomer.TESTFIELD("IC Partner Code");
        //     ICPartner.GET("IC Partner Code");
        //     IF ICCompInfo.CHANGECOMPANY(ICPartner."Inbox Details") THEN BEGIN
        //         "Customer Name" := '';
        //         ICCompInfo.GET;
        //         "Shipper Name" := ICCompInfo."COD Department";
        //         "Shipper Street" := ICCompInfo."COD Address 1";
        //         "Shipper City and State" := ICCompInfo."COD City" + ', ' + ICCompInfo."COD State";
        //         "Shipper Zip" := ICCompInfo."COD Zip Code";
        //         DoFillLocInfo := FALSE;
        //     END;
        // END;

        IF NOT DoFillLocInfo THEN
            EXIT;
        // change it to use based on location.
        Location.RESET;
        Location.SETRANGE("Directed Put-away and Pick", TRUE);
        IF Location.FINDFIRST THEN BEGIN
            "Shipper Name" := Location.Name;
            "Shipper Street" := Location.Address;
            "Shipper City and State" := Location.City + ', ' + Location.County;
            "Shipper Zip" := Location."Post Code";
            "Shipper Telephone" := Location."Phone No.";
        END ELSE BEGIN
            CompanyInfo.GET;
            "Shipper Name" := CompanyInfo."Ship-to Name";
            "Shipper Street" := CompanyInfo."Ship-to Address";
            "Shipper City and State" := CompanyInfo."Ship-to City" + ', ' + CompanyInfo."Ship-to County";
            "Shipper Zip" := CompanyInfo."Ship-to Post Code";
        END;
        //EN1.13 + EN1.20
    end;

    procedure TotalNoOfPallets(): Integer
    var
        BillOfLadingDet: Record "WMS Bill of Lading Header ELA";
    begin
        // EXIT(BillOfLadingDet.GetTotalPalletCount("No."));     //<<EN1.06
    end;

    // procedure SendASN()
    // var
    //     RepSendASN: Report "50192";
    // begin
    //     //<<EN1.19
    //     RepSendASN.SetGlobalVariable(FALSE,TRUE,Rec."No.");
    //     RepSendASN.SETTABLEVIEW(EDITradePartner);
    //     RepSendASN.USEREQUESTPAGE(FALSE);
    //     RepSendASN.RUN;
    //     //>>EN1.19
    // end;
}

