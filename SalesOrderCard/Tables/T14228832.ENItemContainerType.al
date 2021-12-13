table 14228832 "Item Container Type ELA"
{
    DataClassification = ToBeClassified;
    
    fields
    {
        field(1;"Item No."; Code[20])
        {
            TableRelation = Item;
            NotBlank = true;
            DataClassification = ToBeClassified;
        }
        field(2; "Delivery Zone Code"; Code[20])
        {
            TableRelation = "Delivery Zone ELA";
            DataClassification = ToBeClassified;
        }
        field(3; "Container Type"; Code[20])
        {
            DataClassification = ToBeClassified;
        }
        field(4; "Container Type Description"; Text[50])
        {
            DataClassification = ToBeClassified;
        }
    }
    
    keys
    {
        key(Key1; "Item No.","Delivery Zone Code")
        {
            Clustered = true;
        }
    }
    
    var
        myInt: Integer;
    
    trigger OnInsert()
    begin
        
    end;
    
    trigger OnModify()
    begin
        
    end;
    
    trigger OnDelete()
    begin
        
    end;
    
    trigger OnRename()
    begin
        
    end;
    
}