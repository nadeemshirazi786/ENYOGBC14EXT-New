table 14229432 "Rebate Entry ELA"
{
    // ENRE1.00 2021-09-08 AJ
    // ENRE1.00
    //            - Added new field Rebate Type
    //            - Added new key Source Document Type,Source Document No.,Source Document Line No.,Rebate Type
    // 
    // ENRE1.00
    //              - change second key to --> Functional Area,Source Type,Source No.,Source Line No.,Rebate Type,Rebate Code,Posting Date
    // 
    // ENRE1.00
    //              - Added new fields:
    //              81 "Currency Code (RBT)"
    //              91 "Currency Code (DOC)"
    // 
    // ENRE1.00
    //           - New Fields Added
    //              - Pay-to Vendor No.
    //              - Pay-to Name
    //              - Buy-from Vendor No.
    //              - Buy-from Vendor Name
    //              - Order Address Code
    //              - Ship-to Vendor Name
    //              - Accrual Vendor No.
    //              - Accrual Vendor Name
    //              - Purch. Rebate Description
    //            - Modified Field
    //              - Rebate Code (Conditional Table Relation)
    //            - Modified Function
    //              - GetRebateHeader
    //              - Rebate Code - OnValidate
    //              - Source No. - OnValidate
    //              - ShowSourceDoc
    //            - New Function
    //              - ShowRebateCard
    // 
    // ENRE1.00
    //              - Modified Function
    //              - ShowSourceDoc
    //            - Modified Field
    //              - Rebate Type - New Option:Guaranteed Cost Deal
    // 


    DrillDownPageID = "Rebate Entries ELA";

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
                lrecSalesHeader: Record "Sales Header";
                lrecPurchHeader: Record "Purchase Header";
            begin
                //<ENRE1.00>
                case "Functional Area" of
                    "Functional Area"::Sales:
                        begin
                            //</ENRE1.00>
                            if lrecSalesHeader.Get("Source Type", "Source No.") then begin
                                Validate("Bill-To Customer No.", lrecSalesHeader."Bill-to Customer No.");
                                Validate("Sell-to Customer No.", lrecSalesHeader."Sell-to Customer No.");
                                Validate("Ship-To Code", lrecSalesHeader."Ship-to Code");
                            end else begin
                                Clear("Bill-To Customer No.");
                                Clear("Sell-to Customer No.");
                            end;
                        end;
                    //<ENRE1.00>
                    "Functional Area"::Purchase:
                        begin
                            if lrecPurchHeader.Get("Source Type", "Source No.") then begin
                                Validate("Pay-to Vendor No.", lrecPurchHeader."Pay-to Vendor No.");
                                "Pay-to Name" := lrecPurchHeader."Pay-to Name";
                                Validate("Buy-from Vendor No.", lrecPurchHeader."Buy-from Vendor No.");
                                "Buy-from Vendor Name" := lrecPurchHeader."Buy-from Vendor Name";
                                Validate("Sell-to Customer No.", lrecPurchHeader."Sell-to Customer No."); //</PD30382JYJ>
                                Validate("Order Address Code", lrecPurchHeader."Ship-to Code");
                                "Ship-to Vendor Name" := lrecPurchHeader."Ship-to Name";
                            end else begin
                                Clear("Pay-to Vendor No.");
                                Clear("Pay-to Name");
                                Clear("Buy-from Vendor No.");
                                Clear("Buy-from Vendor Name");
                                Clear("Order Address Code");
                                Clear("Ship-to Vendor Name");
                            end;
                        end;
                end;
                //</ENRE1.00>
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
            begin
                GetRebateHeader;

                //<ENRE1.00>
                case "Functional Area" of
                    "Functional Area"::Sales:
                        begin
                            //</ENRE1.00>
                            "Rebate Type" := grecRebateHeader."Rebate Type";
                            "G/L Posting Only" :=
                              grecRebateHeader."Post to Sub-Ledger" = grecRebateHeader."Post to Sub-Ledger"::"Do Not Post";
                            //<ENRE1.00>
                        end;
                    "Functional Area"::Purchase:
                        begin
                            "Rebate Type" := grecPurchRebateHeader."Rebate Type";
                            "G/L Posting Only" :=
                              grecPurchRebateHeader."Post to Sub-Ledger" = grecPurchRebateHeader."Post to Sub-Ledger"::"Do Not Post";
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
        }
        field(80; "Amount (RBT)"; Decimal)
        {
            AutoFormatType = 2;
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
        }
        field(91; "Currency Code (DOC)"; Code[10])
        {
            Caption = 'Currency Code (DOC)';
            Description = 'ENRE1.00';
            TableRelation = Currency;
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
        field(140; "Bill-To Customer No."; Code[20])
        {
            Editable = false;
            TableRelation = Customer;
        }
        field(145; "Bill-To Customer Name"; Text[100])
        {
            CalcFormula = Lookup(Customer.Name WHERE("No." = FIELD("Bill-To Customer No.")));
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
        field(158; "Ship-To Code"; Code[10])
        {
            Description = 'ENRE1.00';
            TableRelation = "Ship-to Address".Code WHERE("Customer No." = FIELD("Sell-to Customer No."));
        }
        field(159; "Ship-To Name"; Text[100])
        {
            CalcFormula = Lookup("Ship-to Address".Name WHERE("Customer No." = FIELD("Sell-to Customer No."),
                                                               Code = FIELD("Ship-To Code")));
            Description = 'ENRE1.00';
            Editable = false;
            FieldClass = FlowField;
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
        field(210; "Rebate Type"; Option)
        {
            Description = 'ENRE1.00';
            OptionCaption = 'Off-Invoice,Everyday,Lump Sum,Sales-Based,Commodity';
            OptionMembers = "Off-Invoice",Everyday,"Lump Sum","Sales-Based",Commodity;
        }
        field(220; "Rebate Unit Rate (LCY)"; Decimal)
        {
            AutoFormatType = 2;
            Caption = 'Rebate Unit Value ($)';
        }
        field(230; "Rebate Unit Rate (RBT)"; Decimal)
        {
            AutoFormatType = 2;
        }
        field(240; "Rebate Unit Rate (DOC)"; Decimal)
        {
            AutoFormatType = 2;
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
        field(283; "Item Rebate Group Code"; Code[20])
        {
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = "Rebate Group ELA".Code;
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
    }

    keys
    {
        key(Key1; "Entry No.")
        {
            Clustered = true;
        }
        key(Key2; "Functional Area", "Source Type", "Source No.", "Source Line No.", "Rebate Type", "Rebate Code", "Posting Date")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key3; "Rebate Code")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key4; "Bill-To Customer No.", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key5; "Sell-to Customer No.", "Ship-To Code", "Rebate Code")
        {
            MaintainSIFTIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
        key(Key6; "Source Type", "Source No.", "Source Line No.", "Rebate Type")
        {
            MaintainSIFTIndex = false;
            MaintainSQLIndex = false;
            SumIndexFields = "Amount (LCY)", "Amount (RBT)", "Amount (DOC)";
        }
    }

    fieldgroups
    {
    }

    var
        grecRebateHeader: Record "Rebate Header ELA";
        grecItem: Record Item;
        grecPurchRebateHeader: Record "Purchase Rebate Header ELA";


    procedure ShowSourceDoc()
    var
        lrecSalesHeader: Record "Sales Header";
        lrecPurchHeader: Record "Purchase Header";
    begin
        //<ENRE1.00>
        case "Functional Area" of
            "Functional Area"::Sales:
                begin
                    //</ENRE1.00>
                    lrecSalesHeader.SetRange("Document Type", "Source Type");
                    lrecSalesHeader.SetRange("No.", "Source No.");
                    case "Source Type" of
                        "Source Type"::Order:
                            begin
                                PAGE.Run(PAGE::"Sales Order", lrecSalesHeader);
                            end;
                        "Source Type"::Invoice:
                            begin
                                PAGE.Run(PAGE::"Sales Invoice", lrecSalesHeader);
                            end;
                        "Source Type"::"Credit Memo":
                            begin
                                PAGE.Run(PAGE::"Sales Credit Memo", lrecSalesHeader);
                            end;
                        "Source Type"::"Return Order":
                            begin
                                PAGE.Run(PAGE::"Sales Return Order", lrecSalesHeader);
                            end;
                    end;
                    //<ENRE1.00>
                end;
            "Functional Area"::Purchase:
                begin
                    if "Rebate Type" <> "Rebate Type"::"Sales-Based" then begin //<ENRE1.00>
                        lrecPurchHeader.SetRange("Document Type", "Source Type");
                        lrecPurchHeader.SetRange("No.", "Source No.");
                        case "Source Type" of
                            "Source Type"::Order:
                                begin

                                    PAGE.Run(PAGE::"Purchase Order", lrecPurchHeader);

                                end;
                            "Source Type"::Invoice:
                                begin


                                    PAGE.Run(PAGE::"Purchase Invoice", lrecPurchHeader);

                                end;
                            "Source Type"::"Credit Memo":
                                begin

                                    PAGE.Run(PAGE::"Purchase Credit Memo", lrecPurchHeader);

                                end;
                            "Source Type"::"Return Order":
                                begin

                                    PAGE.Run(PAGE::"Purchase Return Order", lrecPurchHeader);

                                end;
                        end;
                        //<ENRE1.00>
                    end else begin
                        lrecSalesHeader.SetRange("Document Type", "Source Type");
                        lrecSalesHeader.SetRange("No.", "Source No.");
                        case "Source Type" of
                            "Source Type"::Order:
                                begin

                                    PAGE.Run(PAGE::"Sales Order", lrecSalesHeader);

                                end;
                            "Source Type"::Invoice:
                                begin

                                    PAGE.Run(PAGE::"Sales Invoice", lrecSalesHeader);

                                end;
                            "Source Type"::"Credit Memo":
                                begin

                                    PAGE.Run(PAGE::"Sales Credit Memo", lrecSalesHeader);

                                end;
                            "Source Type"::"Return Order":
                                begin

                                    PAGE.Run(PAGE::"Sales Return Order", lrecSalesHeader);

                                end;
                        end;

                    end;
                end;
        end;
        //</ENRE1.00>
    end;


    procedure GetRebateHeader()
    begin
        //<ENRE1.00>
        case "Functional Area" of
            "Functional Area"::Sales:
                begin
                    //</ENRE1.00>
                    if "Rebate Code" <> '' then begin
                        grecRebateHeader.Get("Rebate Code");
                    end else begin
                        Clear(grecRebateHeader);
                    end;
                end;
            //<ENRE1.00>
            "Functional Area"::Purchase:
                begin
                    if "Rebate Code" <> '' then begin
                        grecPurchRebateHeader.Get("Rebate Code");
                    end else begin
                        Clear(grecPurchRebateHeader);
                    end;
                end;
        end;
        //</ENRE1.00>
    end;


    procedure UpdateRebateRates()
    var
        lrecSalesLine: Record "Sales Line";
    begin
        "Rebate Unit Rate (LCY)" := 0;
        "Rebate Unit Rate (RBT)" := 0;
        "Rebate Unit Rate (DOC)" := 0;

        case "Source Type" of
            "Source Type"::Quote,
            "Source Type"::Order,
            "Source Type"::Invoice,
            "Source Type"::"Credit Memo",
            "Source Type"::"Blanket Order",
            "Source Type"::"Return Order":
                begin
                    if lrecSalesLine.Get("Source Type", "Source No.", "Source Line No.") then begin
                        if lrecSalesLine.Quantity <> 0 then begin
                            "Rebate Unit Rate (LCY)" := Round("Amount (LCY)" / lrecSalesLine.Quantity, 0.00001);
                            "Rebate Unit Rate (RBT)" := Round("Amount (RBT)" / lrecSalesLine.Quantity, 0.00001);
                            "Rebate Unit Rate (DOC)" := Round("Amount (DOC)" / lrecSalesLine.Quantity, 0.00001);
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
    end;


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

