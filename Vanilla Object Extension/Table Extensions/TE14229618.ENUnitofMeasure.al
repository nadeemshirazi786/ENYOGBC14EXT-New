tableextension 14229618 "EN Unit of Measure ELA" extends "Unit of Measure"
{
    fields
    {
        field(14229400; "UOM Group Code ELA"; Code[10])
        {
            DataClassification = ToBeClassified;
            Description = 'ENRE1.00';
            TableRelation = "Unit of Measure Group ELA";
            Caption = 'UOM Group Code';
            trigger OnValidate()
            begin

                if "UOM Group Code ELA" <> '' then
                    "Std. Qty. Per UOM ELA" := 1
                else
                    "Std. Qty. Per UOM ELA" := 0;

            end;
        }
        field(14229401; "Std. Qty. Per UOM ELA"; Decimal)
        {
            DataClassification = ToBeClassified;
            DecimalPlaces = 0 : 15;
            Description = 'ENRE1.00';
            Caption = 'Std. Qty. Per Unit of Measure';

            trigger OnValidate()
            begin

                if "UOM Group Code ELA" <> '' then
                    TestField("Std. Qty. Per UOM ELA");

            end;
        }
        field(14229100; "Type ELA"; Enum "EN Dimension Type")
        {
            Caption = 'EN Dimension Type';
            DataClassification = ToBeClassified;
        }
    }


}