<?php

declare(strict_types=1);

namespace Freyr\Template;

class Initializer
{
    public function __construct()
    {
    }

    public function add(int $a, int $b): int
    {
        return $a + $b;
    }
}
