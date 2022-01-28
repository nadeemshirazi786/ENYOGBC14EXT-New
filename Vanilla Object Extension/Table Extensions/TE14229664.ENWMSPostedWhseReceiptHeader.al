
/// <summary>
/// TableExtension EN WMS Posted Whse Receipt Hdr (ID 14229240) extends Record Posted Whse. Receipt Header.
/// </summary>
tableextension 14229240 "WMS Pstd Whse Receipt Hdr ELA" extends "Posted Whse. Receipt Header"
{
    fields
    {
        field(14229200; "Source Doc. No. ELA"; Code[10])
        {
            Caption = 'Source Doc. No.';
            DataClassification = ToBeClassified;
        }
    }
}
