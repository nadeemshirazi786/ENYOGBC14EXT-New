tableextension 51014 TCompanyInfoExt extends "Company Information"
{
    fields
    {
        field(51000; "Language Code"; Code[10])
        {
            TableRelation = Language;
            DataClassification = ToBeClassified;
        }
    }

}