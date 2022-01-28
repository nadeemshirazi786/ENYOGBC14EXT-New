/// <summary>
/// TableExtension ENWMS Postd Whse. Receipt Line (ID 14229241) extends Record Posted Whse. Receipt Line.
/// </summary>
tableextension 14229241 "WMS Pstd Whse Receipt Line ELA" extends "Posted Whse. Receipt Line"
{
    fields
    {

        field(14229220; "Received By ELA"; Code[20])
        {
            Caption = 'Received By';
            DataClassification = ToBeClassified;
        }

        field(14229221; "Vendor Shipment No. ELA"; Code[20])
        {
            Caption = 'Vendor Shipment No.';
            DataClassification = ToBeClassified;
        }

        field(14229222; "No. of Pallets ELA"; Decimal)
        {
            Caption = 'No. of Pallets';
            DataClassification = ToBeClassified;
        }

        field(14229223; "Received Date ELA"; Date)
        {
            Caption = 'Received Date';
            DataClassification = ToBeClassified;
        }

        field(14229224; "Received Time ELA"; Time)
        {
            Caption = 'Received Time';
            DataClassification = ToBeClassified;
        }
    }

    trigger OnInsert()
    var
    begin
        if "Received By ELA" = '' then
            "Received By ELA" := UserId();

        // "Received Date" := Today;
        // "Received Time" := time;
    end;
}
