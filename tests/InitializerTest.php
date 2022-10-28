<?php

use Freyr\Template\Initializer;
use PHPUnit\Framework\TestCase;

class InitializerTest extends TestCase
{
    public function test_if_added_is_working()
    {
        $initializer = new Initializer();
        $result = $initializer->add(4, 5);
        self::assertEquals(9, $result);
    }
}
