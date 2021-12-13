table 14229436 "Rebate Ledger Entry ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //            - Added new field Rebate Type
    //            - Added new key Functional Area, Source Document Type,Source Document No.,Source Document Line No.,Rebate Type
    // 
    // ENRE1.00
    //           - change second key to -->
    //               Functional Area,Source Type,Source No.,Source Line No.,Rebate Code,Posted To G/L,Paid To Customer,Posting Date
    //            - add field
    //              * 250 Rebate Cancellation Entry
    //             - add key -->
    //                Functional Area,Accrual Customer No.,Rebate Code,Posting Date,Posted To G/L,Paid To Customer
    // 
    // ENRE1.00
    //      
    //     new field: "Schedule For Processing"
    //     - "marks" the record for the scheduled batch posting report 23019640 "Post Scheduled Rebate Entries"
    // 
    // ENRE1.00
    //           - Added new fields:
    //              81 "Currency Code (RBT)"
    //              91 "Currency Code (DOC)"
    // 
    // ENRE1.00
    //           - add Job fields for Tradespend
    //            - add key --> Job No.,Job Task No.,Rebate Code w/SIFT: Amount (LCY),Amount (RBT),Amount (DOC)
    // 
    // ENRE1.00
    //           - New key:
    //             Source Type,Source No.,Source Line No.,Accrual Customer No.,Rebate Code,Posted To G/L,Posted To Customer,G/L Accrual Onl
    // 
    // ENRE1.00
    //              - New Fields Added
    //              - Pay-to Vendor No.
    //              - Pay-to Name
    //              - Buy-from Vendor No.
    //              - Buy-from Vendor Name
    //              - Order Address Code
    //              - Ship-to Vendor Name
    //              - Paid By Vendor
    //              - Posted To Vendor
    //              - Accrual Vendor No.
    //              - Accrual Vendor Name
    //              - Purch. Rebate Description
    //            - Modified Field
    //              - Rebate Code - TableRelation
    //            - Modified Function
    //              - ShowSourceDoc
    //              - Rebate Code - OnValidate
    //            - New Function
    //              - ShowRebateCard
    //            - New Key
    //              - Functional Area,Source Type,Source No.,Source Line No.,Rebate Type,Rebate Code,Posted To G/L,Paid By Vendor
    //              - Source Type,Source No.,Source Line No.,Accrual Vendor No.,Rebate Code,Posted To G/L,Posted To Vendor,G/L Accrual Only
    //              - Functional Area,Source Type,Source No.,Source Line No.,Rebate Code,Posted To G/L,Paid By Vendor,Posting Date
    //              - Rebate Code,Posting Date,Posted To G/L,Paid By Vendor,Rebate Type
    //              - Functional Area,Accrual Vendor No.,Rebate Code,Posting Date,Posted To G/L,
    //                G/L Accrual Only,Posted To Vendor,Paid By Vendor
    //              - Accrual Vendor No.,Rebate Code
    // 
    // ENRE1.00
    //              - New Fields
    //              - ShowSourceDoc
    //            - Modified Field
    //              - Rebate Type - New Option:Guaranteed Cost Deal
    // 

    // 

    // 
    // 
    // ENRE1.00
    //           - new fields:
    //              510 Claimed
    //              511 Claimed Datetime
    //              512 Claim Reference No.
    //            - Fix Accrual Vendor No. tablerelation
    //            - new key


    DrillDownPageID = "Rebate Ledger Entries ELA";
    LookupPageID = "Rebate Ledger Entries ELA";

    fields
    {
        field(10; "Entry No."; Integer)
        {
        }
        field(20; "Functional Area"; Option)
        {
            OptionCaption = 'Sales,Purchase';
            OptionMembers = Sales,Purchase;
        }
        field(30; "Source Type"; Option)
        {
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(40; "Source No."; Code[20])
        {

            trigger OnValidate()
            var
                lrecSalesInvHeader: Record "Sales Invoice Header";
                lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
            begin
                Clear("Bill-to Customer No.");
                Clear("Sell-to Customer No.");
                Clear("Posting Date");

                if "Source No." <> '' then begin
                    case "Source Type" of
                        "Source Type"::"Posted Invoice":
                            begin
                                if lrecSalesInvHeader.Get("Source No.") then begin
                                    Validate("Bill-to Customer No.", lrecSalesInvHeader."Bill-to Customer No.");
                                    Validate("Sell-to Customer No.", lrecSalesInvHeader."Sell-to Customer No.");
                                    Validate("Posting Date", lrecSalesInvHeader."Posting Date");
                                end;
                            end;
                        "Source Type"::"Posted Cr. Memo":
                            begin
                                if lrecSalesCrMemoHeader.Get("Source No.") then begin
                                    Validate("Bill-to Customer No.", lrecSalesCrMemoHeader."Bill-to Customer No.");
                                    Validate("Sell-to Customer No.", lrecSalesCrMemoHeader."Sell-to Customer No.");
                                    Validate("Posting Date", lrecSalesCrMemoHeader."Posting Date");
                                end;
                            end;
                    end;
                end;
            end;
        }
        field(50; "Source Line No."; Integer)
        {
        }
        field(55; "Posting Date"; Date)
        {
        }
        field(60; "Rebate Code"; Code[20])
        {
            TableRelation = IF ("Functional Area" = FILTER(Sales)) "Rebate Header ELA".Code
            ELSE
            IF ("Functional Area" = FILTER(Purchase)) "Purchase Rebate Header ELA".Code;

            trigger OnValidate()
            var
                lrecRebate: Record "Rebate Header ELA";
                lrecPurchRebate: Record "Purchase Rebate Header ELA";
            begin
                //<ENRE1.00>
                case "Functional Area" of
                    "Functional Area"::Sales:
                        begin
                            //</ENRE1.00>
                            if lrecRebate.Get("Rebate Code") then begin
                                "Rebate Type" := lrecRebate."Rebate Type";
                                "G/L Posting Only" :=
                                  lrecRebate."Post to Sub-Ledger" = lrecRebate."Post to Sub-Ledger"::"Do Not Post";
                            end;
                            //<ENRE1.00>
                        end;
                    "Functional Area"::Purchase:
                        begin
                            if lrecPurchRebate.Get("Rebate Code") then begin
                                "Rebate Type" := lrecPurchRebate."Rebate Type";
                                "G/L Posting Only" :=
                                  lrecPurchRebate."Post to Sub-Ledger" = lrecPurchRebate."Post to Sub-Ledger"::"Do Not Post";
                            end;
                        end;
                end;
                //</ENRE1.00>
            end;
        }
        field(65; "Item No."; Code[20])
        {
            TableRelation = Item;

            trigger OnValidate()
            begin
                Clear(grecItem);

                if "Item No." <> '' then begin
                    grecItem.Get("Item No.");
                end;

                "Item Rebate Group Code" := grecItem."Rebate Group Code ELA";
            end;
        }
        field(70; "Amount (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Amount ($)';

            trigger OnValidate()
            begin
                UpdateRebateRates;
            end;
        }
        field(80; "Amount (RBT)"; Decimal)
        {
            AutoFormatType = 2;

            trigger OnValidate()
            begin
                UpdateRebateRates;
            end;
        }
        field(81; "Currency Code (RBT)"; Code[10])
        {
            Caption = 'Currency Code (RBT)';
            Description = 'ENRE1.00';
            TableRelation = Currency;
        }
        field(90; "Amount (DOC)"; Decimal)
        {
            AutoFormatType = 2;

            trigger OnValidate()
            begin
                UpdateRebateRates;
            end;
        }
        field(91; "Currency Code (DOC)"; Code[10])
        {
            Caption = 'Currency Code (DOC)';
            Description = 'ENRE1.00';
            TableRelation = Currency;
        }
        field(100; "Posted To G/L"; Boolean)
        {
        }
        field(110; Adjustment; Boolean)
        {
        }
        field(120; "Rebate Document No."; Code[20])
        {
        }
        field(130; "Rebate Description"; Text[50])
        {
            CalcFormula = Lookup("Rebate Header ELA".Description WHERE(Code = FIELD("Rebate Code")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(131; "Purch. Rebate Description"; Text[50])
        {
            CalcFormula = Lookup("Purchase Rebate Header ELA".Description WHERE(Code = FIELD("Rebate Code")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(140; "Bill-to Customer No."; Code[20])
        {
            Editable = false;
            TableRelation = Customer;
        }
        field(145; "Bill-to Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Bill-to Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(150; "Sell-to Customer No."; Code[20])
        {
            TableRelation = Customer."No.";
        }
        field(155; "Sell-to Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Sell-to Customer No.")));
            Editable = false;
            FieldClass = FlowField;
        }
        field(158; "Ship-to Code"; Code[10])
        {
            Description = 'ENRE1.00';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(159; "Ship-to Name"; Text[100])
        {
            CalcFormula = Lookup("Ship-to Address".Name WHERE("Customer No." = FIELD("Sell-to Customer No."),
                                                               Code = FIELD("Ship-to Code")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(160; "Date Created"; Date)
        {
            Editable = false;
        }
        field(170; "Paid to Customer"; Boolean)
        {
        }
        field(180; "Pay-to Vendor No."; Code[20])
        {
            Caption = 'Pay-to Vendor No.';
            Description = 'ENRE1.00';
            NotBlank = true;
            TableRelation = Vendor;
        }
        field(181; "Pay-to Name"; Text[50])
        {
            Caption = 'Name';
            Description = 'ENRE1.00';
        }
        field(182; "Buy-from Vendor No."; Code[20])
        {
            Caption = 'Buy-from Vendor No.';
            Description = 'ENRE1.00';
            TableRelation = Vendor;
        }
        field(183; "Buy-from Vendor Name"; Text[50])
        {
            Caption = 'Buy-from Vendor Name';
            Description = 'ENRE1.00';
        }
        field(184; "Order Address Code"; Code[10])
        {
            Caption = 'Ship-to Code';
            Description = 'ENRE1.00';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(185; "Ship-to Vendor Name"; Text[50])
        {
            Caption = 'Ship-to Name';
            Description = 'ENRE1.00';
        }
        field(190; "Rebate Batch Name"; Code[10])
        {
            Caption = 'Rebate Batch Name';
            TableRelation = "Rebate Batch ELA".Name;
        }
        field(200; "Reason Code"; Code[10])
        {
            Caption = 'Reason Code';
            TableRelation = "Reason Code";
        }
        field(210; "Rebate Type"; Option)
        {
            Description = 'ENRE1.00';
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum,Sales-Based,Commodity';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum","Sales-Based",Commodity;
        }
        field(220; "Rebate Unit Rate (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rebate Unit Rate ($)';
        }
        field(230; "Rebate Unit Rate (RBT)"; Decimal)
        {
            AutoFormatType = 2;
        }
        field(240; "Rebate Unit Rate (DOC)"; Decimal)
        {
            AutoFormatType = 2;
        }
        field(250; "Rebate Cancellation Entry"; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(260; "Post-to Customer No."; Code[20])
        {
            Description = 'ENRE1.00';
            TableRelation = Customer;
        }
        field(270; "Post-to Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Post-to Customer No.")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(281; "G/L Posting Only"; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(282; "Posted To Customer"; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(283; "Item Rebate Group Code"; Code[20])
        {
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = "Rebate Group ELA".Code;
        }
        field(284; "Job No."; Code[20])
        {
            Description = 'ENRE1.00';
        }
        field(285; "Job Task No."; Code[20])
        {
            Description = 'ENRE1.00';
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No."));
        }
        field(500; "Schedule For Processing"; Boolean)
        {
            Caption = 'Schedule For Processing';
            Description = 'ENRE1.00';
        }
        field(501; "Paid-by Vendor"; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(502; "Posted To Vendor"; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(503; "Post-to Vendor No."; Code[20])
        {
            Description = 'ENRE1.00';
            TableRelation = Vendor;
        }
        field(504; "Post-to Vendor Name"; Text[100])
        {
            CalcFormula = Lookup(Vendor.Name WHERE("No." = FIELD("Post-to Vendor No.")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
        }
        field(510; Claimed; Boolean)
        {
            Description = 'ENRE1.00';
        }
        field(511; "Claimed Datetime"; DateTime)
        {
            Description = 'ENRE1.00';
        }
        field(512; "Claim Reference No."; Code[10])
        {
            Description = 'ENRE1.00';
            Editable = false;
        }
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key2; "Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Code", "Posted To G/L", "Paid to Customer", "Posting Date")
        {
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key3; "Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Code", "Posted To G/L", "Paid-by Vendor", "Posting Date")
        {
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key4; "Rebate Code", "Posting Date", "Posted To G/L", "Paid to Customer", "Rebate Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key5; "Rebate Code", "Posting Date", "Posted To G/L", "Paid-by Vendor", "Rebate Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key6; "Bill-to Customer No.", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key7; "Sell-to Customer No.", "Ship-to Code", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key8; "Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Type", "Rebate Code", "Posted To G/L", "Paid to Customer")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key9; "Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Type", "Rebate Code", "Posted To G/L", "Paid-by Vendor")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key10; "Bill-to Customer No.", "Item No.", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key11; "Sell-to Customer No.", "Ship-to Code", "Item No.", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
        }
        key(Key12; "Functional Area", "Source Type", "Source No.", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key13; "Functional Area", "Post-to Customer No.", "Rebate Code", "Posting Date", "Posted To G/L", "G/L Posting Only", "Posted To Customer", "Paid to Customer")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key14; "Functional Area", "Post-to Vendor No.", "Rebate Code", "Posting Date", "Posted To G/L", "G/L Posting Only", "Posted To Vendor", "Paid-by Vendor")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key15; "Post-to Customer No.", "Rebate Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key16; "Post-to Vendor No.", "Rebate Code")
        {
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key17; "Job No.", "Job Task No.", "Rebate Code")
        {
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key18; "Source Type", "Source No.", "Source Line No.", "Post-to Customer No.", "Rebate Code", "Posted To G/L", "Posted To Customer", "G/L Posting Only")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key19; "Source Type", "Source No.", "Source Line No.", "Post-to Vendor No.", "Rebate Code", "Posted To G/L", "Posted To Vendor", "G/L Posting Only")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key20; "Pay-to Vendor No.", "Functional Area", "Source Type", "Source No.", "Source Line No.", "Item No.", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
    }

    fieldgroups
    {
    }

    trigger OnInsert()
    begin
        "Date Created" := WorkDate;
    end;

    var
        grecItem: Record Item;


    procedure ShowSourceDoc()
    var
        lrecSalesInvHeader: Record "Sales Invoice Header";
        lrecSalesCrMemoHeader: Record "Sales Cr.Memo Header";
        lrecCustomer: Record Customer;
        lrecVendor: Record Vendor;
        lrecPurchInvHeader: Record "Purch. Inv. Header";
        lrecPurchCrMemoHeader: Record "Purch. Cr. Memo Hdr.";
    begin
        //<ENRE1.00>
        case "Functional Area" of
            "Functional Area"::Sales:
                begin
                    //</ENRE1.00>
                    case "Source Type" of
                        "Source Type"::"Posted Invoice":
                            begin
                                lrecSalesInvHeader.SetRange("No.", "Source No.");
                                PAGE.Run(PAGE::"Posted Sales Invoice", lrecSalesInvHeader);
                            end;
                        "Source Type"::"Posted Cr. Memo":
                            begin
                                lrecSalesCrMemoHeader.SetRange("No.", "Source No.");
                                PAGE.Run(PAGE::"Posted Sales Credit Memo", lrecSalesCrMemoHeader);
                            end;
                        "Source Type"::Customer:
                            begin
                                lrecCustomer.SetRange("No.", "Source No.");
                                PAGE.Run(PAGE::"Customer Card", lrecCustomer);
                            end;
                        "Source Type"::Vendor:
                            begin
                                lrecVendor.SetRange("No.", "Source No.");
                                PAGE.Run(PAGE::"Vendor Card", lrecVendor);
                            end;
                    end;
                    //<ENRE1.00>
                end;
            "Functional Area"::Purchase:
                begin
                    if "Rebate Type" <> "Rebate Type"::"Sales-Based" then begin //<ENRE1.00>
                        case "Source Type" of
                            "Source Type"::"Posted Invoice":
                                begin
                                    lrecPurchInvHeader.SetRange("No.", "Source No.");

                                    PAGE.Run(PAGE::"Posted Purchase Invoice", lrecPurchInvHeader);

                                end;
                            "Source Type"::"Posted Cr. Memo":
                                begin
                                    lrecPurchCrMemoHeader.SetRange("No.", "Source No.");

                                    PAGE.Run(PAGE::"Posted Purchase Credit Memo", lrecPurchCrMemoHeader);

                                end;
                            "Source Type"::Vendor:
                                begin
                                    lrecVendor.SetRange("No.", "Source No.");

                                    PAGE.Run(PAGE::"Vendor Card", lrecVendor);
                                end;

                        end;
                        //<ENRE1.00>
                    end else begin
                        case "Source Type" of
                            "Source Type"::"Posted Invoice":
                                begin
                                    lrecSalesInvHeader.SetRange("No.", "Source No.");


                                    PAGE.Run(PAGE::"Posted Sales Invoice", lrecSalesInvHeader);

                                end;
                            "Source Type"::"Posted Cr. Memo":
                                begin
                                    lrecSalesCrMemoHeader.SetRange("No.", "Source No.");

                                    PAGE.Run(PAGE::"Posted Sales Credit Memo", lrecSalesCrMemoHeader);

                                end;
                        end;
                    end;
                    //</ENRE1.00>
                end;
        end;
        //</ENRE1.00>
    end;


    procedure UpdateRebateRates()
    var
        lrecSalesInvLine: Record "Sales Invoice Line";
        lrecSalesCrMemoLine: Record "Sales Cr.Memo Line";
        lrecPurchInvLine: Record "Purch. Inv. Line";
        lrecPurchCrMemoLine: Record "Purch. Cr. Memo Line";
    begin
        "Rebate Unit Rate (LCY)" := 0;
        "Rebate Unit Rate (RBT)" := 0;
        "Rebate Unit Rate (DOC)" := 0;

        //<ENRE1.00>
        case "Functional Area" of
            "Functional Area"::Sales:
                begin
                    //</ENRE1.00>
                    case "Source Type" of
                        "Source Type"::"Posted Invoice":
                            begin
                                if lrecSalesInvLine.Get("Source No.", "Source Line No.") then begin
                                    if lrecSalesInvLine.Quantity <> 0 then begin
                                        "Rebate Unit Rate (LCY)" := Round("Amount (LCY)" / lrecSalesInvLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (RBT)" := Round("Amount (RBT)" / lrecSalesInvLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (DOC)" := Round("Amount (DOC)" / lrecSalesInvLine.Quantity, 0.00001);
                                    end;
                                end;
                            end;
                        "Source Type"::"Posted Cr. Memo":
                            begin
                                if lrecSalesCrMemoLine.Get("Source No.", "Source Line No.") then begin
                                    if lrecSalesCrMemoLine.Quantity <> 0 then begin
                                        "Rebate Unit Rate (LCY)" := Round("Amount (LCY)" / lrecSalesCrMemoLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (RBT)" := Round("Amount (RBT)" / lrecSalesCrMemoLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (DOC)" := Round("Amount (DOC)" / lrecSalesCrMemoLine.Quantity, 0.00001);
                                    end;
                                end;
                            end;
                        "Source Type"::Customer:
                            begin
                                "Rebate Unit Rate (LCY)" := "Amount (LCY)";
                                "Rebate Unit Rate (RBT)" := "Amount (RBT)";
                                "Rebate Unit Rate (DOC)" := "Amount (DOC)";
                            end;
                    end;
                    //<ENRE1.00>
                end;
            "Functional Area"::Purchase:
                begin
                    case "Source Type" of
                        "Source Type"::"Posted Invoice":
                            begin
                                if lrecPurchInvLine.Get("Source No.", "Source Line No.") then begin
                                    if lrecPurchInvLine.Quantity <> 0 then begin
                                        "Rebate Unit Rate (LCY)" := Round("Amount (LCY)" / lrecPurchInvLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (RBT)" := Round("Amount (RBT)" / lrecPurchInvLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (DOC)" := Round("Amount (DOC)" / lrecPurchInvLine.Quantity, 0.00001);
                                    end;
                                end;
                            end;
                        "Source Type"::"Posted Cr. Memo":
                            begin
                                if lrecPurchCrMemoLine.Get("Source No.", "Source Line No.") then begin
                                    if lrecPurchCrMemoLine.Quantity <> 0 then begin
                                        "Rebate Unit Rate (LCY)" := Round("Amount (LCY)" / lrecPurchCrMemoLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (RBT)" := Round("Amount (RBT)" / lrecPurchCrMemoLine.Quantity, 0.00001);
                                        "Rebate Unit Rate (DOC)" := Round("Amount (DOC)" / lrecPurchCrMemoLine.Quantity, 0.00001);
                                    end;
                                end;
                            end;
                        "Source Type"::Vendor:
                            begin
                                "Rebate Unit Rate (LCY)" := "Amount (LCY)";
                                "Rebate Unit Rate (RBT)" := "Amount (RBT)";
                                "Rebate Unit Rate (DOC)" := "Amount (DOC)";
                            end;
                    end;
                end;
        end;
        //</ENRE1.00>
    end;


    // procedure RebateAdjustment()
    // var
    //     lrecRebateJnlLine: Record "Rebate Journal Line";
    //     lfrmCreateRebateAdj: Page "Create Rebate Adjustment";
    //     ldecAdjustmentAmount: Decimal;
    //     lcodReasonCode: Code[10];
    //     ltxtUser: Text[65];
    //     lcodToBatchName: Code[10];
    //     lText000: Label 'Default';
    //     lrecRebateBatch: Record "Rebate Batch";
    // begin
    //     //<ENRE1.00>

    //     //Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor
    //     case "Source Type" of
    //         "Source Type"::"Posted Invoice", "Source Type"::"Posted Cr. Memo":
    //             begin
    //                 ltxtUser := UpperCase(UserId); // Uppercase in case of Windows Login

    //                 if ltxtUser <> '' then begin
    //                     lcodToBatchName := CopyStr(ltxtUser, 1, MaxStrLen(lrecRebateJnlLine."Rebate Batch Name"))
    //                 end else begin
    //                     lcodToBatchName := lText000;
    //                 end;

    //                 if not lrecRebateBatch.Get(lcodToBatchName) then begin
    //                     lrecRebateBatch.Name := lcodToBatchName;
    //                     lrecRebateBatch.Description := lcodToBatchName;
    //                     lrecRebateBatch.Insert(true);
    //                 end;

    //                 Commit;

    //                 if lfrmCreateRebateAdj.RunModal = ACTION::Yes then begin
    //                     lfrmCreateRebateAdj.ReturnPostingInfo(ldecAdjustmentAmount, lcodReasonCode);
    //                     lrecRebateJnlLine."Rebate Batch Name" := lcodToBatchName;
    //                     lrecRebateJnlLine."Line No." := 10000;
    //                     lrecRebateJnlLine."Document Type" := lrecRebateJnlLine."Document Type"::Adjustment;
    //                     lrecRebateJnlLine."Document No." := 'TEST';
    //                     lrecRebateJnlLine."Applies-To Customer No." := "Post-to Customer No.";
    //                     case "Source Type" of
    //                         "Source Type"::"Posted Invoice":
    //                             begin
    //                                 lrecRebateJnlLine."Applies-To Source Type" := lrecRebateJnlLine."Applies-To Source Type"::"Posted Sales Invoice";
    //                             end;
    //                         "Source Type"::"Posted Cr. Memo":
    //                             begin
    //                                 lrecRebateJnlLine."Applies-To Source Type" := lrecRebateJnlLine."Applies-To Source Type"::"Posted Sales Cr. Memo";
    //                             end;
    //                     end;

    //                     lrecRebateJnlLine."Applies-To Source No." := "Source No.";
    //                     lrecRebateJnlLine."Applies-To Source Line No." := "Source Line No.";
    //                     lrecRebateJnlLine."Rebate Code" := "Rebate Code";
    //                     lrecRebateJnlLine."Posting Date" := WorkDate;
    //                     lrecRebateJnlLine."Amount (LCY)" := ldecAdjustmentAmount;
    //                     lrecRebateJnlLine."Reason Code" := lcodReasonCode;
    //                     lrecRebateJnlLine.Adjustment := true;
    //                     lrecRebateJnlLine.Insert;
    //                     CODEUNIT.Run(23019653, lrecRebateJnlLine);
    //                 end;


    //             end;
    //     end;

    //     //</ENRE1.00>
    // end;


    procedure ShowRebateCard()
    var
        lrecRebateHeader: Record "Rebate Header ELA";
        lrecPurchRebateHeader: Record "Purchase Rebate Header ELA";
    begin
        //<ENRE1.00>
        case "Functional Area" of
            "Functional Area"::Sales:
                begin
                    lrecRebateHeader.Get("Rebate Code");

                    PAGE.RunModal(PAGE::"Rebate Card ELA", lrecRebateHeader);

                end;
            "Functional Area"::Purchase:
                begin
                    lrecPurchRebateHeader.Get("Rebate Code");

                    PAGE.RunModal(PAGE::"Purchase Rebate Card ELA", lrecPurchRebateHeader);

                end;
        end;
        //</ENRE1.00>
    end;
}

