tableextension 14229612 "EN Customer Ledger Entry ELA" extends "Cust. Ledger Entry"
{
    fields
    {
        field(14229400; "Rebate Code ELA"; Code[20])
        {
            Caption = 'Rebate Code';
            Description = 'ENRE1.00';
            TableRelation = IF ("Rbt Accrual Customer No. ELA" = FILTER(<> '')) "Rebate Header ELA".Code
            ELSE
            IF ("Rebate Accrual Vendor No. ELA" = FILTER(<> '')) "Purchase Rebate Header ELA".Code;

            trigger OnValidate()
            begin

                case true of
                    "Rbt Accrual Customer No. ELA" <> '':
                        begin


                            if "Rebate Code ELA" <> '' then begin
                                grecRebate.Get("Rebate Code ELA");
                                "Rebate Category Code ELA" := grecRebate."Rebate Category Code";
                            end else begin
                                Clear("Rebate Category Code ELA");
                            end;

                        end;
                    "Rebate Accrual Vendor No. ELA" <> '':
                        begin
                            if "Rebate Code ELA" <> '' then begin
                                grecPurchRebate.Get("Rebate Code ELA");
                                "Rebate Category Code ELA" := grecPurchRebate."Rebate Category Code";
                            end else begin
                                Clear("Rebate Category Code ELA");
                            end;
                        end;
                end;

            end;
        }
        field(14229401; "Rebate Source Type ELA"; Option)
        {
            Caption = 'Rebate Source Type';
            Description = 'ENRE1.00';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(14229402; "Rebate Source No. ELA"; Code[20])
        {
            Caption = 'Rebate Source No.';
            Description = 'ENRE1.00';
        }
        field(14229403; "Rebate Source Line No. ELA"; Integer)
        {
            Caption = 'Rebate Source Line No';
            Description = 'ENRE1.00';
        }
        field(14229404; "Rebate Document No. ELA"; Code[20])
        {
            Caption = 'Rebate Document No.';
            Description = 'ENRE1.00';
        }
        field(14229405; "Posted Rebate Entry No. ELA"; Integer)
        {
            Caption = 'Posted Rebate Entry No.';
            Description = 'ENRE1.00';
        }
        field(14229406; "Rbt Accrual Customer No. ELA"; Code[20])
        {
            Caption = 'Rebate Accrual Customer No.';
            Description = 'ENRE1.00';
        }
        field(14229407; "Rebate Customer No. ELA"; Code[20])
        {
            Caption = 'Rebate Customer No.';
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                Cust: Record Customer;
            begin

                if "Rebate Customer No. ELA" <> '' then begin
                    Cust.Get("Rebate Customer No. ELA");

                    "Customer Rebate Group ELA" := Cust."Rebate Group Code ELA";
                end else begin
                    Clear("Customer Rebate Group ELA");
                end;

            end;
        }
        field(14229408; "Rebate Item No. ELA"; Code[20])
        {
            Caption = 'Rebate Item No.';
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if "Rebate Item No. ELA" <> '' then begin
                    grecItem.Get("Rebate Item No. ELA");

                    "Item Rebate Group ELA" := grecItem."Rebate Group Code ELA";
                end else begin
                    Clear("Item Rebate Group ELA");
                end;

            end;
        }
        field(14229409; "Rebate Category Code ELA"; Code[20])
        {
            Caption = 'Rebate Category Code';
            Description = 'ENRE1.00';
        }
        field(14229410; "Customer Rebate Group ELA"; Code[20])
        {
            Caption = 'Customer Rebate Group';
            Description = 'ENRE1.00';
        }
        field(14229411; "Item Rebate Group ELA"; Code[20])
        {
            Caption = 'Item Rebate Group';
            Description = 'ENRE1.00';
        }
        field(14229412; "Rebate Accrual Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Accrual Vendor No.';
            Description = 'ENRE1.00';
        }
        field(14229413; "Rebate Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin

                if "Rebate Vendor No. ELA" <> '' then begin
                    Vend.Get("Rebate Vendor No. ELA");
                    "Vendor Rebate Group ELA" := Vend."Rebate Group Code ELA";
                end else begin
                    Clear("Vendor Rebate Group ELA");
                end;

            end;
        }
        field(14229414; "Vendor Rebate Group ELA"; Code[20])
        {
            Caption = 'Vendor Rebate Group';
            Description = 'ENRE1.00';
        }
        field(14229415; "Inv For Bill of Lading No. ELA"; Code[20])
        {
            Caption = 'Invoice For Bill of Lading No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14229416; "Invoice For Shipment No. ELA"; Code[20])
        {
            Caption = 'Invoice For Shipment No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14229417; "Comment ELA"; Text[80])
        {
            Caption = 'Comment';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229418; "Job No. ELA"; Code[20])
        {
            Caption = 'Job No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = Job;
        }
        field(14229419; "Job Task No. ELA"; Code[20])
        {
            Caption = 'Job Task No';
            Description = 'ENRE1.00';
            Editable = false;
            TableRelation = "Job Task"."Job Task No." WHERE("Job No." = FIELD("Job No. ELA"),
                                                             "Job Task No." = FIELD("Job Task No. ELA"));
        }
    }
    var
        grecItem: Record Item;
        grecRebate: Record "Rebate Header ELA";

        grecPurchRebate: Record "Purchase Rebate Header ELA";

    procedure OnSalesPaymentELA(VAR FoundPaymentLine: Record "EN Sales Payment Line"): Boolean
    var
        SalesPaymentLine: Record "EN Sales Payment Line";
    begin
        //<ENSP1.00
        SalesPaymentLine.SETCURRENTKEY(Type, "Entry No.");
        SalesPaymentLine.SETRANGE(Type, SalesPaymentLine.Type::"Open Entry");
        SalesPaymentLine.SETRANGE("Entry No.", "Entry No.");
        IF SalesPaymentLine.FINDFIRST THEN BEGIN
            FoundPaymentLine := SalesPaymentLine;
            EXIT(TRUE);
        END;
        //>>ENSP1.00
    end;

    procedure IsSalesPaymentTenderELA(VAR FoundTenderEntry: Record "EN Sales Payment Tender Entry"): Boolean
    var
        SalesTenderEntry: Record "EN Sales Payment Tender Entry";
        SalesPayment: Record "EN Sales Payment Header";
    begin
        //<<ENSP1.00
        SalesTenderEntry.SETCURRENTKEY("Cust. Ledger Entry No.");
        SalesTenderEntry.SETRANGE("Cust. Ledger Entry No.", "Entry No.");
        IF SalesTenderEntry.FINDFIRST THEN
            IF SalesPayment.GET(SalesTenderEntry."Document No.") THEN BEGIN
                FoundTenderEntry := SalesTenderEntry;
                EXIT(TRUE);
            END;
        //>>ENSP1.00
    end;

    procedure IsSalesPaymentInvoiceELA(VAR FoundPayment: Record "EN Sales Payment Header"): Boolean
    var
        SalesPayment: Record "EN Sales Payment Header";
    begin
        //<<ENSP1.00
        SalesPayment.SETCURRENTKEY("Min. Posting Entry No.", "Max. Posting Entry No.");
        SalesPayment.SETFILTER("Min. Posting Entry No.", '..%1', "Entry No.");
        SalesPayment.SETFILTER("Max. Posting Entry No.", '%1..', "Entry No.");
        IF SalesPayment.FINDLAST THEN BEGIN
            FoundPayment := SalesPayment;
            EXIT(TRUE);
        END;
        //>>ENSP1.00
    end;
}