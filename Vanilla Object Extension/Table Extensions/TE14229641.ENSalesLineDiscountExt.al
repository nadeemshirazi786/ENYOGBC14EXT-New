tableextension 14228863 "EN Sales Line Discount Ext" extends "Sales Line Discount"
{
    fields
    {
        field(14228850; "Line Discount Type ELA"; Option)
        {
            Caption = 'Line Discount Type';
            OptionCaption = 'Percent,Amount';
            OptionMembers= Percent,Amount;
            DataClassification = ToBeClassified;
        }
    }
}
