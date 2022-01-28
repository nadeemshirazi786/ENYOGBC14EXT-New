tableextension 51014 TCompanyInfoExt extends "Company Information"
{
    fields
    {
        field(51000; "Language Code"; Code[10])
        {
            TableRelation = Language;
            DataClassification = ToBeClassified;
        }
		field(14229200; "Enabled For WMS"; Boolean)
        {
            DataClassification = ToBeClassified;
        }
    }

}