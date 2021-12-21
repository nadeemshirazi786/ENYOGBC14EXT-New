table 14228811 "Country of Origin"
{
    // Copyright Axentia Solutions Corp.  1999-2009.
    // By opening this object you acknowledge that this object includes confidential information and intellectual
    // property of Axentia Solutions Corp. and that this work is protected by Canadian, U.S. and international
    // copyright laws and agreements.
    // 
    // JF02278AC
    //   20090213
    //     - new object
    // 
    //   20090616
    //     - add County Code table relation to new County of Origin table


    fields
    {
        field(60; "Country/Region Code"; Code[10])
        {
            Caption = 'Country/Region Code';
            NotBlank = true;
            TableRelation = "Country/Region";
        }
        field(70; "County Code"; Code[10])
        {
            Caption = 'State Code';
            TableRelation = County.Code WHERE("Country/Region Code" = FIELD("Country/Region Code"));
        }
    }

    keys
    {
        key(Key1; "Country/Region Code", "County Code")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }
}

