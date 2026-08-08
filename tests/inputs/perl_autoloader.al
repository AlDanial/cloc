# NOTE: Derived from ../../lib/Example/Client.pm.
# Changes made here will be lost when autosplit is run again.
# See AutoSplit.pm.
package Example::Client;

#line 214 "../../lib/Example/Client.pm (autosplit into ../../lib/auto/Example/Client/fetch_page.al)"
sub fetch_page {
    my ($self, $url) = @_;
    my ($page, $response, %headers) = $self->request(GET => $url);
    my $value = $headers{'content-length'};

    # The report below is only printed in verbose mode; see the man page.
    if ($self->{verbose}) {
        printf("interface %s returned %d bytes\n", $self->{iface}, $value);
    }

    return $page;
}

1;
