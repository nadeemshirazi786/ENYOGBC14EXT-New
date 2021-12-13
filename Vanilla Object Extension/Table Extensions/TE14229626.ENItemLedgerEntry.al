tableextension 14229626 "EN Item Ledger Entry ELA" extends "Item Ledger Entry"
{
    fields
    {
        field(14228850; "Reporting UOM ELA"; Code[10])
        {
            Caption = 'Reporting UOM';
            DataClassification = ToBeClassified;
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
        }
        field(14228851; "Reporting Qty. ELA"; Decimal)
        {
            Caption = 'Reporting Qty.';
            DataClassification = ToBeClassified;
        }
        field(14228852; "Rep. Qty. per UOM ELA"; Decimal)
        {
            Caption = 'Rep. Qty. per Unit of Measure';
            DataClassification = ToBeClassified;
        }
        field(14228900; "Supply Chain Group Code ELA"; Code[10])
        {
            Caption = 'Supply Chain Group Code';
            DataClassification = ToBeClassified;
        }
        field(14228901; "Country/Reg of Origin Code ELA"; Code[10])
        {
            Caption = 'Country/Region of Origin Code';
            DataClassification = ToBeClassified;
        }
        field(14229120; "Order Type Ext ELA"; Enum "EN Order type")
        {
            Caption = 'Order Type Ext';
            DataClassification = ToBeClassified;

        }
        field(14229121; "Writeoff Responsibility ELA"; Enum "EN Write off Responsiblity Type")
        {
            Caption = 'Writeoff Responsibility';
            DataClassification = ToBeClassified;
        }
        field(14229150; "Release Date ELA"; Date)
        {
            Caption = 'ELA Release Date';
            DataClassification = ToBeClassified;
        }
        field(14229151; "Reason Code ELA"; Code[10])
        {

            Caption = 'Reason Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Reason Code";
        }
        field(14229400; "Net Weight ELA"; Decimal)
        {
            Caption = 'Net Weight';
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 5;
            Description = 'ENRE1.00';
        }
        field(14229401; "Quality Measure Code ELA"; Code[20])
        {
            Caption = 'Quality Measure Code';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
        }
        field(14229403; "Employee No. ELA"; Code[20])
        {
            Caption = 'Employee No.';
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = Employee;
        }

    }
    procedure GetCostingQtyELA(): Decimal
    begin
        EXIT(Quantity);
    end;

    procedure GetCostingInvQtyELA(): Decimal
    begin
        EXIT("Invoiced Quantity");
    end;




    var
        myInt: Integer;

    trigger OnInsert()
    begin

    end;

    trigger OnModify()
    begin

    end;

    trigger OnDelete()
    begin

    end;

    trigger OnRename()
    begin

    end;

}