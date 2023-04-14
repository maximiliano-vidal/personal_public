package com.edsa.factory.model.repositories;

import org.springframework.stereotype.Repository;

import com.edsa.factory.model.entities.Account;
import com.fwk.arqrestapis.repository.CommonRepository;

@Repository
public interface AccountRepository extends CommonRepository<Account, Long>{}