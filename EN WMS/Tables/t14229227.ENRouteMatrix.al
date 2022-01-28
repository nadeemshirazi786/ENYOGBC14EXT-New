table 14229227 "Route Matrix ELA"
{
    DataClassification = ToBeClassified;
    Caption = 'Route Matrix';
    fields
    {
        field(1; Active; Boolean)
        {
            DataClassification = ToBeClassified;
        }
        field(2; Monday; Boolean)
        {

        }
        field(3; Tuesday; Boolean)
        {

        }
        field(4; Wednesday; Boolean)
        {

        }
        field(5; Thursday; Boolean)
        {

        }
        field(6; Friday; Boolean)
        {

        }
        field(7; Saturday; Boolean)
        {

        }
        field(8; Sunday; Boolean)
        {

        }
        field(9; "Location Code"; Code[20])
        {
            TableRelation = Location;
        }
        field(10; "Customer Code"; Code[20])
        {
            TableRelation = Customer;
        }
        field(11; "Route Code"; Code[20])
        {
            TableRelation = "Delivery Route ELA";
        }
    }

    keys
    {
        key(PrimaryKey; Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday, "Location Code", "Customer Code")
        {
            Clustered = true;
        }
    }

}