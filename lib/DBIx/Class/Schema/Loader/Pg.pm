package DBIx::Class::Schema::Loader::Pg;

use strict;
use base 'DBIx::Class::Schema::Loader::Generic';
use Carp;

=head1 NAME

DBIx::Class::Schema::Loader::Pg - DBIx::Class::Schema::Loader Postgres Implementation.

=head1 SYNOPSIS

  use DBIx::Class::Schema::Loader;

  # $loader is a DBIx::Class::Schema::Loader::Pg
  my $loader = DBIx::Class::Schema::Loader->new(
    dsn       => "dbi:Pg:dbname=dbname",
    user      => "postgres",
    password  => "",
  );

=head1 DESCRIPTION

See L<DBIx::Class::Schema::Loader>.

=cut

sub _loader_db_classes {
    return qw/DBIx::Class::PK::Auto::Pg/;
}

sub _loader_tables {
    my $class = shift;
    my $dbh = $class->storage->dbh;

    # This is split out to avoid version parsing errors...
    my $is_dbd_pg_gte_131 = ( $DBD::Pg::VERSION >= 1.31 );
    my @tables = $is_dbd_pg_gte_131 ? 
        $dbh->tables( undef, $class->_loader_data->{db_schema}, "", "table", { noprefix => 1, pg_noprefix => 1 } )
        : $dbh->tables;

    s/"//g for @tables;
    return @tables;
}

sub _loader_table_info {
    my ( $class, $table ) = @_;
    my $dbh = $class->storage->dbh;

    my $sth = $dbh->column_info(undef, $class->_loader_data->{db_schema}, $table, undef);
    my @cols = map { $_->[3] } @{ $sth->fetchall_arrayref };
    s/"//g for @cols;
    
    my @primary = $dbh->primary_key(undef, $class->_loader_data->{db_schema}, $table);

    s/"//g for @primary;

    return ( \@cols, \@primary );
}

=head1 SEE ALSO

L<DBIx::Class::Schema::Loader>

=cut

1;
