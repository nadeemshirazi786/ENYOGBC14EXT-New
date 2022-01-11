tableextension 14229403 "Gen. Journal Line ELA" extends "Gen. Journal Line"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        // Add changes to table fields here
        field(14228800; "Rebate Code ELA"; Code[20])
        {
            Caption = 'Rebate Code';
            Description = 'ENRE1.00';
            TableRelation = IF ("Rebate Accrual Customer No." = FILTER(<> '')) "Rebate Header ELA".Code
            ELSE
            IF ("Rebate Accrual Vendor No. ELA" = FILTER(<> '')) "Purchase Rebate Header ELA".Code;

            trigger OnValidate()
            begin

                case true of
                    "Rebate Accrual Customer No." <> '':
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
        field(14228801; "Rebate Source Type ELA"; Option)
        {
            Caption = 'Rebate Source Type';
            Description = 'ENRE1.00';
            OptionCaption = 'Quote,Order,Invoice,Credit Memo,Blanket Order,Return Order,Posted Invoice,Posted Cr. Memo,Customer,Vendor';
            OptionMembers = Quote,"Order",Invoice,"Credit Memo","Blanket Order","Return Order","Posted Invoice","Posted Cr. Memo",Customer,Vendor;
        }
        field(14228802; "Rebate Source No. ELA"; Code[20])
        {
            Caption = 'Rebate Source No.';
            Description = 'ENRE1.00';
        }
        field(14228803; "Rebate Source Line No. ELA"; Integer)
        {
            Caption = 'Rebate Source Line No.';
            Description = 'ENRE1.00';
        }
        field(14228804; "Rebate Document No. ELA"; Code[20])
        {
            Caption = 'Rebate Document No.';
            Description = 'ENRE1.00';
        }
        field(14228805; "Posted Rebate Entry No. ELA"; Integer)
        {
            Caption = 'Posted Rebate Entry No.';
            Description = 'ENRE1.00';
        }
        field(14228806; "Rebate Accrual Customer No."; Code[20])
        {
            Caption = 'Rebate Accrual Customer No.';
            Description = 'ENRE1.00';
        }
        field(14228807; "Rebate Customer No. ELA"; Code[20])
        {
            Description = 'ENRE1.00';
            Caption = 'Rebate Customer No.';
            trigger OnValidate()
            var
                Cust: Record Customer;
            begin

                if "Rebate Item No. ELA" <> '' then begin
                    Cust.Get("Rebate Item No. ELA");

                    "Customer Rebate Group ELA" := Cust."Rebate Group Code ELA";
                end else begin
                    Clear("Customer Rebate Group ELA");
                end;

            end;
        }
        field(14228808; "Rebate Item No. ELA"; Code[20])
        {
            Caption = 'Rebate Item No.';
            Description = 'ENRE1.00';

            trigger OnValidate()
            begin

                if "Rebate Category Code ELA" <> '' then begin
                    grecItem.Get("Rebate Category Code ELA");

                    "Item Rebate Group ELA" := grecItem."Rebate Group Code ELA";
                end else begin
                    Clear("Item Rebate Group ELA");
                end;

            end;
        }
        field(14228809; "Rebate Category Code ELA"; Code[20])
        {
            Caption = 'Rebate Category Code';
            Description = 'ENRE1.00';
        }
        field(14228810; "Customer Rebate Group ELA"; Code[20])
        {
            Caption = 'Customer Rebate Group';
            Description = 'ENRE1.00';
        }
        field(14228811; "Item Rebate Group ELA"; Code[20])
        {
            Caption = 'Item Rebate Group';
            Description = 'ENRE1.00';
        }
        field(14228812; "Rebate Accrual Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Accrual Vendor No.';
            Description = 'ENRE1.00';
        }
        field(14228813; "Rebate Vendor No. ELA"; Code[20])
        {
            Caption = 'Rebate Vendor No.';
            Description = 'ENRE1.00';

            trigger OnValidate()
            var
                Vend: Record Vendor;
            begin

                if "Rebate Accrual Vendor No. ELA" <> '' then begin
                    Vend.Get("Rebate Accrual Vendor No. ELA");
                    "Rebate Vendor No. ELA" := Vend."Rebate Group Code ELA";
                end else begin
                    Clear("Rebate Vendor No. ELA");
                end;

            end;
        }
        field(14228814; "Vendor Rebate Group ELA"; Code[20])
        {
            Caption = 'Vendor Rebate Group';
            Description = 'ENRE1.00';
        }
        field(14228815; "Inv For Bill of Lading No ELA"; Code[20])
        {
            Caption = 'Invoice For Bill of Lading No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14228816; "Invoice For Shipment No. ELA"; Code[20])
        {
            Caption = 'Invoice For Shipment No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            Editable = false;
        }
        field(14228817; "Bank Reference No. ELA"; Code[20])
        {
            Caption = 'Bank Reference No.';
            DataClassification = ToBeClassified;
        }
    }

    var
        myInt: Integer;
        grecRebate: Record "Rebate Header ELA";
        grecPurchRebate: Record "Purchase Rebate Header ELA";
        grecItem: Record Item;
}