tableextension 14229400 "Salesperson Ext. ELA" extends "Salesperson/Purchaser"
{
    //ENRE1.00 2021-09-08 AJ
    fields
    {
        field(14228800; "Rebate Group Code ELA"; Code[20])
        {

            TableRelation = "Rebate Group ELA";
            DataClassification = ToBeClassified;
        }
    }

}