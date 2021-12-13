tableextension 14228860 "EN Stockkeeping Unit Ext" extends "Stockkeeping Unit"
{
    fields
    {
        field(14228880; "Allow Multi-UOM Bin Contnt ELA"; Boolean)
        {
            Caption = 'Allow Multi-UOM Bin Content';
            DataClassification = ToBeClassified;
        }
        field(14228850; "Block From Purch Doc ELA"; Boolean)
        {
            Caption = 'Block From Purchase Documents';
            DataClassification = ToBeClassified;
        }
        field(14228851; "Block From Sales Doc ELA"; Boolean)
        {
            Caption = 'Block From Sales Documents';
            DataClassification = ToBeClassified;
        }
    }
}