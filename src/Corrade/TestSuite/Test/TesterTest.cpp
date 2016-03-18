/*
    This file is part of Corrade.

    Copyright © 2007, 2008, 2009, 2010, 2011, 2012, 2013, 2014, 2015, 2016
              Vladimír Vondruš <mosra@centrum.cz>

    Permission is hereby granted, free of charge, to any person obtaining a
    copy of this software and associated documentation files (the "Software"),
    to deal in the Software without restriction, including without limitation
    the rights to use, copy, modify, merge, publish, distribute, sublicense,
    and/or sell copies of the Software, and to permit persons to whom the
    Software is furnished to do so, subject to the following conditions:

    The above copyright notice and this permission notice shall be included
    in all copies or substantial portions of the Software.

    THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
    IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
    FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL
    THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
    LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING
    FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
    DEALINGS IN THE SOFTWARE.
*/

#include <cstdlib>
#include <sstream>

#include "Corrade/TestSuite/Tester.h"

namespace Corrade { namespace TestSuite {

class StringLength;

template<> class Comparator<StringLength> {
    public:
        Comparator(int epsilon = 0): epsilon(epsilon) {}

        bool operator()(const std::string& actual, const std::string& expected) {
            return std::abs(int(actual.size()) - int(expected.size())) <= epsilon;
        }

        void printErrorMessage(Utility::Error& e, const std::string& actual, const std::string& expected) const {
            e << "Length of actual" << actual << "doesn't match length of expected" << expected << "with epsilon" << epsilon;
        }

    private:
        int epsilon;
};

class StringLength {
    public:
        StringLength(int epsilon = 0): c(epsilon) {}

        Comparator<StringLength> comparator() { return c; }

    private:
        Comparator<StringLength> c;
};

namespace Test {

struct Test: Tester {
    Test(std::ostream* out);

    void noChecks();
    void trueExpression();
    void falseExpression();
    void equal();
    void nonEqual();
    void expectFail();
    void unexpectedPassExpression();
    void unexpectedPassEqual();

    void compareAs();
    void compareAsFail();
    void compareWith();
    void compareWithFail();
    void compareImplicitConversionFail();

    void skip();

    void setupTeardown();
    void setupTeardownEmpty();
    void setupTeardownError();
    void setupTeardownSkip();

    void setup();
    void teardown();

    std::ostream* _out;
};

Test::Test(std::ostream* const out): _out{out} {
    addTests({&Test::noChecks,
              &Test::trueExpression,
              &Test::falseExpression,
              &Test::equal,
              &Test::nonEqual,
              &Test::expectFail,
              &Test::unexpectedPassExpression,
              &Test::unexpectedPassEqual,

              &Test::compareAs,
              &Test::compareAsFail,
              &Test::compareWith,
              &Test::compareWithFail,
              &Test::compareImplicitConversionFail,

              &Test::skip});

    addTests({&Test::setupTeardown,
              &Test::setupTeardownEmpty,
              &Test::setupTeardownError,
              &Test::setupTeardownSkip},
              &Test::setup,
              &Test::teardown);
}

void Test::noChecks() {
    return;
}

void Test::trueExpression() {
    CORRADE_VERIFY(true); // #1
}

void Test::falseExpression() {
    CORRADE_VERIFY(5 != 5); // #2
}

void Test::equal() {
    CORRADE_COMPARE(3, 3); // #3
}

void Test::nonEqual() {
    int a = 5;
    int b = 3;
    CORRADE_COMPARE(a, b); // #4
}

void Test::expectFail() {
    {
        CORRADE_EXPECT_FAIL("The world is not mad yet.");
        CORRADE_COMPARE(2 + 2, 5); // #5
        CORRADE_VERIFY(false == true); // #6
    }

    CORRADE_VERIFY(true); // #7

    {
        CORRADE_EXPECT_FAIL_IF(6*7 == 49, "This is not our universe");
        CORRADE_VERIFY(true); // #8
    }
}

void Test::unexpectedPassExpression() {
    CORRADE_EXPECT_FAIL("Not yet implemented.");
    CORRADE_VERIFY(true == true); // #9
}

void Test::unexpectedPassEqual() {
    CORRADE_EXPECT_FAIL("Cannot get it right.");
    CORRADE_COMPARE(2 + 2, 4); // #10
}

void Test::compareAs() {
    CORRADE_COMPARE_AS("kill!", "hello", StringLength); // #11
}

void Test::compareAsFail() {
    CORRADE_COMPARE_AS("meh", "hello", StringLength); // #12
}

void Test::compareWith() {
    CORRADE_COMPARE_WITH("You rather GTFO", "hello", StringLength(10)); // #13
}

void Test::compareWithFail() {
    CORRADE_COMPARE_WITH("You rather GTFO", "hello", StringLength(9)); // #14
}

void Test::compareImplicitConversionFail() {
    std::string hello{"hello"};
    CORRADE_COMPARE("holla", hello); // #15
}

void Test::skip() {
    CORRADE_SKIP("This testcase is skipped.");
    CORRADE_VERIFY(false); // (not called)
}

void Test::setup() {
    Debug{_out} << "       [" << Debug::nospace << testCaseId() << Debug::nospace << "] setting up...";
}

void Test::teardown() {
    Debug{_out} << "       [" << Debug::nospace << testCaseId() << Debug::nospace << "] tearing down...";
}

void Test::setupTeardown() {
    CORRADE_VERIFY(true);
}

void Test::setupTeardownEmpty() {}

void Test::setupTeardownError() {
    CORRADE_VERIFY(false);
}

void Test::setupTeardownSkip() {
    CORRADE_SKIP("Skipped.");
}

struct TesterTest: Tester {
    explicit TesterTest();

    void test();
    void emptyTest();
    void skipOnly();

    void compareNoCommonType();
    void compareAsOverload();
    void compareAsVarargs();
    void compareNonCopyable();
    void verifyExplicitBool();
    void expectFailIfExplicitBool();
};

class EmptyTest: public Tester {};

TesterTest::TesterTest() {
    addTests({&TesterTest::test,
              &TesterTest::emptyTest,
              &TesterTest::skipOnly,

              &TesterTest::compareNoCommonType,
              &TesterTest::compareAsOverload,
              &TesterTest::compareAsVarargs,
              &TesterTest::compareNonCopyable,
              &TesterTest::verifyExplicitBool,
              &TesterTest::expectFailIfExplicitBool});
}

namespace {
    /* Disable automatic colors to ensure we have the same behavior everywhere */
    const char* noColorArgv[] = { "", "--color", "off" };
    const int noColorArgc = std::extent<decltype(noColorArgv)>();
}

void TesterTest::test() {
    std::stringstream out;

    Test t{&out};
    t.registerTest("here.cpp", "TesterTest::Test");
    int result = t.exec(noColorArgc, noColorArgv, &out, &out);

    CORRADE_VERIFY(result == 1);

    std::string expected =
        "Starting TesterTest::Test with 18 test cases...\n"
        "     ? [01] <unknown>()\n"
        "    OK [02] trueExpression()\n"
        "  FAIL [03] falseExpression() at here.cpp on line 129 \n"
        "        Expression 5 != 5 failed.\n"
        "    OK [04] equal()\n"
        "  FAIL [05] nonEqual() at here.cpp on line 139 \n"
        "        Values a and b are not the same, actual is\n"
        "        5 \n"
        "        but expected\n"
        "        3\n"
        " XFAIL [06] expectFail() at here.cpp on line 145 \n"
        "        The world is not mad yet. 2 + 2 and 5 are not equal.\n"
        " XFAIL [06] expectFail() at here.cpp on line 146 \n"
        "        The world is not mad yet. Expression false == true failed.\n"
        "    OK [06] expectFail()\n"
        " XPASS [07] unexpectedPassExpression() at here.cpp on line 159 \n"
        "        Expression true == true was expected to fail.\n"
        " XPASS [08] unexpectedPassEqual() at here.cpp on line 164 \n"
        "        2 + 2 and 4 are not expected to be equal.\n"
        "    OK [09] compareAs()\n"
        "  FAIL [10] compareAsFail() at here.cpp on line 172 \n"
        "        Length of actual \"meh\" doesn't match length of expected \"hello\" with epsilon 0\n"
        "    OK [11] compareWith()\n"
        "  FAIL [12] compareWithFail() at here.cpp on line 180 \n"
        "        Length of actual \"You rather GTFO\" doesn't match length of expected \"hello\" with epsilon 9\n"
        "  FAIL [13] compareImplicitConversionFail() at here.cpp on line 185 \n"
        "        Values \"holla\" and hello are not the same, actual is\n"
        "        holla \n"
        "        but expected\n"
        "        hello\n"
        "  SKIP [14] skip() \n"
        "        This testcase is skipped.\n"
        "       [15] setting up...\n"
        "    OK [15] setupTeardown()\n"
        "       [15] tearing down...\n"
        "       [16] setting up...\n"
        "     ? [16] <unknown>()\n"
        "       [17] setting up...\n"
        "  FAIL [17] setupTeardownError() at here.cpp on line 208 \n"
        "        Expression false failed.\n"
        "       [17] tearing down...\n"
        "       [18] setting up...\n"
        "  SKIP [18] setupTeardownSkip() \n"
        "        Skipped.\n"
        "       [18] tearing down...\n"
        "Finished TesterTest::Test with 8 errors out of 17 checks. 2 test cases didn't contain any checks!\n";

    //CORRADE_COMPARE(out.str().length(), expected.length());
    CORRADE_COMPARE(out.str(), expected);
}

void TesterTest::emptyTest() {
    std::stringstream out;

    EmptyTest t;
    t.registerTest("here.cpp", "TesterTest::EmptyTest");
    int result = t.exec(noColorArgc, noColorArgv, &out, &out);

    CORRADE_VERIFY(result == 2);

    CORRADE_COMPARE(out.str(), "No tests to run in TesterTest::EmptyTest!\n");
}

void TesterTest::skipOnly() {
    std::stringstream out;

    const char* argv[] = { "", "--color", "off", "--only", "11 14 4 9", "--skip", "14" };
    const int argc = std::extent<decltype(argv)>();

    Test t{&out};
    t.registerTest("here.cpp", "TesterTest::Test");
    int result = t.exec(argc, argv, &out, &out);

    CORRADE_VERIFY(result == 0);

    std::string expected =
        "Starting TesterTest::Test with 3 test cases...\n"
        "    OK [11] compareWith()\n"
        "    OK [04] equal()\n"
        "    OK [09] compareAs()\n"
        "Finished TesterTest::Test with 0 errors out of 3 checks.\n";
    CORRADE_COMPARE(out.str(), expected);
}

void TesterTest::compareNoCommonType() {
    /* Test that this compiles well */
    struct A {
        /*implicit*/ A(int value): value(value) {}
        /*implicit*/ operator int() const { return value; }
        int value;
    };
    CORRADE_COMPARE(A{5}, 5);
}

void TesterTest::compareAsOverload() {
    /* Just test that this compiles well */
    float a = 3.0f;
    double b = 3.0f;
    CORRADE_COMPARE_AS(a, b, float);
    CORRADE_COMPARE_AS(a, b, double);
}

void TesterTest::compareAsVarargs() {
    const std::pair<int, int> a(3, 5);
    const std::pair<float, float> b(3.2f, 5.7f);
    CORRADE_COMPARE_AS(a, b, std::pair<int, int>);
}

namespace {
    struct NonCopyable {
        explicit NonCopyable() = default;
        NonCopyable(const NonCopyable&) = delete;
        NonCopyable(NonCopyable&&) = delete;
        NonCopyable& operator=(const NonCopyable&) = delete;
        NonCopyable& operator=(NonCopyable&&) = delete;
    };

    inline bool operator==(const NonCopyable&, const NonCopyable&) { return true; }
    inline Utility::Debug& operator<<(Utility::Debug& debug, const NonCopyable&) {
        return debug << "NonCopyable";
    }
}

void TesterTest::compareNonCopyable() {
    /* Just to verify that there is no need to copy anything anywhere */
    NonCopyable a, b;
    CORRADE_COMPARE(a, b);
}

void TesterTest::verifyExplicitBool() {
    struct ExplicitTrue { explicit operator bool() const { return true; } };
    ExplicitTrue t;
    CORRADE_VERIFY(t);
    CORRADE_VERIFY(ExplicitTrue());

    struct ExplicitTrueNonConst { explicit operator bool() { return true; } };
    ExplicitTrueNonConst tc;
    CORRADE_VERIFY(tc);
    CORRADE_VERIFY(ExplicitTrueNonConst());

    struct ExplicitFalse { explicit operator bool() const { return false; } };
    ExplicitFalse f;
    CORRADE_VERIFY(!f);
}

void TesterTest::expectFailIfExplicitBool() {
    struct ExplicitFalse { explicit operator bool() const { return false; } };
    {
        ExplicitFalse t;
        CORRADE_EXPECT_FAIL_IF(t, "");
        CORRADE_EXPECT_FAIL_IF(ExplicitFalse{}, "");
        CORRADE_VERIFY(true);
    }

    struct ExplicitFalseNonConst { explicit operator bool() { return false; } };
    {
        ExplicitFalseNonConst t;
        CORRADE_EXPECT_FAIL_IF(t, "");
        CORRADE_EXPECT_FAIL_IF(ExplicitFalseNonConst{}, "");
        CORRADE_VERIFY(true);
    }

    struct ExplicitTrue { explicit operator bool() const { return true; } };
    {
        CORRADE_EXPECT_FAIL_IF(ExplicitTrue{}, "");
        CORRADE_VERIFY(false);
    }
}

}}}

CORRADE_TEST_MAIN(Corrade::TestSuite::Test::TesterTest)
