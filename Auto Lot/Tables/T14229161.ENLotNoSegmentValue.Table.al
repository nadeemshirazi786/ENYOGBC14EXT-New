table 14229161 "EN Lot No. Segment Value ELA"
{

    Caption = 'Lot No. Segment Value';

    fields
    {
        field(1; Type; Option)
        {
            Caption = 'Type';
            OptionCaption = 'Location,Equipment,Shift';
            OptionMembers = Location,Equipment,Shift;

            trigger OnValidate()
            begin
                if Type <> xRec.Type then begin
                    "Code/No." := '';
                    "Segment Value" := '';
                end;
            end;
        }
        field(2; "Code/No."; Code[20])
        {
            Caption = 'Code/No.';
            NotBlank = true;
            TableRelation = IF (Type = CONST(Location)) Location
            ELSE
            IF (Type = CONST(Equipment)) Resource WHERE(Type = CONST(Machine))
            ELSE
            IF (Type = CONST(Shift)) "Work Shift";

            trigger OnValidate()
            begin
                if "Code/No." <> xRec."Code/No." then
                    "Segment Value" := '';
            end;
        }
        field(3; "Segment Value"; Code[5])
        {
            Caption = 'Segment Value';
        }
    }

    keys
    {
        key(Key1; Type, "Code/No.")
        {
            Clustered = true;
        }
    }

    fieldgroups
    {
    }

    [Scope('Internal')]
    procedure Description(): Text[100]
    var
        Location: Record Location;
        Resource: Record Resource;
        WorkShift: Record "Work Shift";
    begin
        if "Code/No." = '' then
            exit('');

        case Type of
            Type::Location:
                begin
                    Location.Get("Code/No.");
                    exit(Location.Name);
                end;
            Type::Equipment:
                begin
                    Resource.Get("Code/No.");
                    exit(Resource.Name);
                end;
            Type::Shift:
                begin
                    WorkShift.Get("Code/No.");
                    exit(WorkShift.Description);
                end;
        end;
    end;

    [Scope('Internal')]
    procedure SetupNewLine(LastLine: Record "EN Lot No. Segment Value ELA")
    begin
        Type := LastLine.Type;
    end;
}

