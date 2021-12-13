tableextension 51012 TItemVendorExt extends "Item Vendor"
{
    fields
    {
        field(51000; "Purchase Price Unit of Measure"; Code[10])
        {
            TableRelation = "Item Unit of Measure".Code WHERE("Item No." = FIELD("Item No."));
            DataClassification = ToBeClassified;
        }
        field(51001; "Status"; Enum ItemVendStatus)
        {
            DataClassification = ToBeClassified;
        }
        field(14229150; "Shelf Life Requirement"; DateFormula)
        {
            DataClassification = ToBeClassified;
        }
    }
}