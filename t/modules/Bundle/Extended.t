use Test2::Bundle::Extended;
use Test2::API qw/test2_stack/;
use PerlIO;
# HARNESS-NO-FORMATTER

imported_ok qw{
    ok pass fail diag note todo skip
    plan skip_all done_testing bail_out

    gen_event

    intercept context

    cmp_ok

    subtest
    can_ok isa_ok DOES_ok
    set_encoding
    imported_ok not_imported_ok
    ref_ok ref_is ref_is_not
    mock mocked

    is like isnt unlike
    match mismatch validator
    hash array object meta number string
    in_set not_in_set check_set
    item field call call_list call_hash prop check all_items all_keys all_vals all_values
    end filter_items
    T F D E DNE FDNE
    event fail_events
    exact_ref
};

ok(Test2::Plugin::ExitSummary->active, "Exit Summary is loaded");
ok(defined(Test2::Plugin::SRand->seed), "SRand is loaded");

subtest strictures => sub {
    local $^H;
    my $hbefore = $^H;
    Test2::Bundle::Extended->import;
    my $hafter = $^H;

    my $strict = do { local $^H; strict->import(); $^H };

    ok($strict,               'sanity, got $^H value for strict');
    ok(!($hbefore & $strict), "strict is not on before loading Test2::Bundle::Extended");
    ok(($hafter & $strict),   "strict is on after loading Test2::Bundle::Extended");
};

subtest warnings => sub {
    local ${^WARNING_BITS};
    my $wbefore = ${^WARNING_BITS} || '';
    Test2::Bundle::Extended->import;
    my $wafter = ${^WARNING_BITS} || '';

    my $warnings = do { local ${^WARNING_BITS}; 'warnings'->import(); ${^WARNING_BITS} || '' };

    ok($warnings, 'sanity, got ${^WARNING_BITS} value for warnings');
    ok($wbefore ne $warnings, "warnings are not on before loading Test2::Bundle::Extended") || diag($wbefore, "\n", $warnings);
    ok(($wafter & $warnings), "warnings are on after loading Test2::Bundle::Extended");
};

subtest utf8 => sub {
    ok(utf8::is_utf8("癸"), "utf8 pragma is on");

    my $layers = { map {$_ => 1} PerlIO::get_layers(STDERR) };
    ok($layers->{utf8}, "utf8 is on for STDERR");

    $layers = { map {$_ => 1} PerlIO::get_layers(STDOUT) };
    ok($layers->{utf8}, "utf8 is on for STDOUT");

    # -2 cause the subtest adds to the stack
    my $format = test2_stack()->[-2]->format;
    my $handles = $format->handles;
    for my $hn (0 .. @$handles) {
        my $h = $handles->[$hn] || next;
        $layers = { map {$_ => 1} PerlIO::get_layers($h) };
        ok($layers->{utf8}, "utf8 is on for formatter handle $hn");
    }
};

done_testing;

1;
